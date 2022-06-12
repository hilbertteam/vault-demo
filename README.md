# vault-demo

## Инструменты и зависимости

1. Terragrunt и Terraform
2. Kubectl
3. Helm, c подключенными репозиториями Hashicorp и nginx-ingress
4. CLI Yandex Cloud - интерфейс командной строки
5. Доменное имя, публичная зона (неважно где она хранится) с прописанными A и CNAME-записями:
 - A: internal.your_domain
 - CNAME: *.internal.you_domain
 (в качестве примера будет использоваться домен example.com)
6. Приватная зона для вашего домена, прописывается в Яндекс Облаке на одном из этапов.
7. Включенная услуга Network Loab Balancer

**Важно:** для работы стенда необходимо запросить в технической поддержке Яндекс облака подключение услугу "Internal Network Load Balancer (с внутренним IP адресом)". По умолчанию на данный момент услуга не подключена и это приведет к невозможности ресурс.

## Развертывание стенда

### Подготовка

1. Создать бакет для хранения state-файлов terraform
2. Создать сервисный аккаунт с ролями `storage.editor` и `storage.uploader`
3. В сервисном аккаунте создать ключ для авторизации.
4. В директории Infra создать файл `secret_values.hcl` с данными для подключения к облаку:
```HCL
locals {
  yc_token     = ""

  s3_access_key = "access key from SA"
  s3_secret_key = "secret key from SA"
  s3_bucket     = "unique bucket name"

}
```

### Часть 1

Переходим в папку Infra/terragrunt и выполняем:

```
terragrunt run-all init
terragrunt run-all apply
```

В случае успешного завершения будут созданы:
 - сети
 - nat-инстанс, 
 - Infra и Prod кластера в Managed Service for Kubernetes
 - таблица маршрутизации тарифка через nat-инстанс для сетей k8s-кластеров и применена к ним

После это необходимо импортировать данные для подключения к кластерам `yc-infra-cluster` и `yc-prod-cluster` (подробнее в документации к Яндекс Облаку)

### Часть 2

В "IP addresses" резервируем публичный IP-адрес. В данном примере `84.252.136.236` 

Создать для домена внутреннюю и внешнюю зоны. Во внешней зоне нужно создать 2 записи:
 - A: `internal.example.com` 84.252.136.236
 - CNAME: `*.internal.example.com`

Для внутренней зоны в Яндекс облаке создать А-запись:
 - A: `vault.internal.example.com` 172.16.21.10

Таким образом, подготовка ДНС завершена.

### Часть 3

На данном этапе все действия выполняются из папки `Values and k8s-manifests`

Переключим контекст:

```bash
kubectl config use-context yc-infra-cluster
```

***Примечание:*** *в случае необходимости переключения контекста будет показана необходимая команда.*

1. Стандартным чартом деплоим nginx-ingress, передавая в качестве параметра публичный IP c предыдущего шага.

```bash
helm -n nginx-ingress-controller upgrade --install \
  nginx-ingress-controller nginx-ingress/ingress-nginx --create-namespace \
  --set controller.metrics.enabled=false \
  --set defaultBackend.enabled=false \
  --set controller.service.loadBalancerIP=84.252.136.236
```

2. Стандартным чартом деплоим CertManager, некоторые значения переопределены в `certmanager-values.yaml`

```bash
helm -n cert-manager upgrade --install \
  cert-manager jetstack/cert-manager \
  --values certmanager-values.yaml \
  --create-namespace
```

3. Создаем Issuer, который подключается к Let's Encrypt и запрашивает у него сертификат

```bash
kubectl -n cert-manager apply -f issuer.yaml
```

4. Создаем Certificate, который отправит запрос на сертификат в Issuer и в случае успеха сохранит в секрет

```bash
kubectl create namespace vault && \
kubectl -n vault apply -f certificate.yaml
```

5. Ставим Vault без Vault Injector

```bash
helm -n vault upgrade --install vault hashicorp/vault \
  --create-namespace --values vault-values.yaml
```

6. Инициализация, распечатывание и логин

Init:
```bash
kubectl -n vault exec vault-0 -- vault operator init \
   -key-shares=1 -key-threshold=1 \
   -format=json | tee vault-init-values.json
```
Unseal
```bash
UNSEAL_KEY=$(cat vault-init-values.json | jq -r '.unseal_keys_hex[0]') && \
kubectl -n vault exec vault-0 -- vault operator unseal $UNSEAL_KEY
```

Login
```bash
ROOT_KEY=$(cat vault-init-values.json | jq -r '.root_token') && \
kubectl -n vault exec vault-0 -- vault login $ROOT_KEY
```

7. Создаем Network Load Balancer

Создаем NLB, предварительно выставив корректный subnet_id в файле vault-lb.

```bash
kubectl -n vault apply -f vault-lb.yaml
```

8. Проверяем сертификат.

```bash
kubectl -n nginx-ingress-controller exec \
  $(kubectl -n nginx-ingress-controller get pod \
  -o jsonpath='{.items[0].metadata.name}') -- \
  openssl s_client -connect vault.internal.example.com:443
```

Если все в порядке, то в конце вывода можно увидеть строку `Verify return code: 0 (ok)`, а выше посмотреть на цепочку. 

9. Подготовка Vault

Включаем KV-хранилище версии 2, путь demo-app
```bash
kubectl -n vault exec vault-0 -- \
  vault secrets enable -path=demo-app kv-v2
```

Сохраняем имя пользователя и пароль
```bash
kubectl -n vault exec vault-0 -- \
  vault kv put demo-app/db/credentials \
  username="db-username" password="db-secret-password"
```

Создаем политику доступа (поскольку kv-v2, то в путь добавляется data)
```bash
kubectl -n vault exec vault-0 -- sh -c 'cat <<EOF | vault policy write demo-app -
path "demo-app/data/db/credentials" {
  capabilities = ["read"]
}
EOF'
```

10. Включаем Kubernetes авторизацию, путь infra-cluster

```bash
kubectl -n vault exec vault-0 -- vault auth enable -path infra-cluster kubernetes
```

11. Создаем роль для пути infra-cluster и задаем данные для подключения (demo-app, demo-app-sa)

```bash
kubectl -n vault exec vault-0 -- \
  vault write auth/infra-cluster/role/demo-app \
        bound_service_account_names=demo-app-sa \
        bound_service_account_namespaces=demo-app \
        policies=demo-app \
        ttl=24h
```

12. Деплоим Vault Injector, путь infra-cluster

```bash
helm -n vault upgrade --install vault-injector  hashicorp/vault \
  --set server.enabled=false  \
  --set injector.enabled=true  \
  --set injector.externalVaultAddr="https://vault.internal.example.com" \
  --set injector.authPath="auth/infra-cluster"
```

13. Создаем config, путь infra-cluster

```bash
kubectl -n vault exec vault-0 -- \
  sh -c '
    vault write auth/infra-cluster/config \
      token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
      kubernetes_ca_cert="$(cat /var/run/secrets/kubernetes.io/serviceaccount/ca.crt)" \
      issuer="kubernetes.default.svc" \
      kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" '
```

14. Деплоим тестовое приложение и проверяем, что видим в консоли имя пользователя и пароль

```bash
kubectl apply -f demo-app.yaml
```

```bash
kubectl -n demo-app logs --tail=10 demo-app
```

15. Получаем сертификат и внутренний IP для Prod-cluster

```bash
terragrunt output -json | jq -r '.claster_certificate.value' > ../../../../Values\ and\ k8s-manifests/prod-CA.crt &&
terragrunt output -json | jq -r '.k8s_internal_ip.value'  > ../../../../Values\ and\ k8s-manifests/prod-internal-ip.txt
```

15. Деплоим Vault Injector в Prod-cluster, путь prod-cluster

```bash
kubectl config use-context yc-prod-cluster 
```

```bash
helm -n vault upgrade --install vault-injector hashicorp/vault \
  --set server.enabled=false  \
  --set injector.enabled=true  \
  --set injector.externalVaultAddr="https://vault.internal.example.com" \
  --set injector.authPath="auth/prod-cluster" \
  --create-namespace
```

17. Получаем токен сервисного аккаунта Vault Injector

```bash
kubectl -n vault get secret \
   $(kubectl -n vault get sa vault-injector -o "jsonpath={.secrets[0].name}") \
   -o "jsonpath={.data.token}" | base64 -d | tee prod-token
```

18. Копируем данные в Infra-cluster

```bash
kubectl config use-context yc-infra-cluster
```

```bash
kubectl -n vault cp ./prod-CA.crt vault-0:/tmp/ && \
kubectl -n vault cp ./prod-token vault-0:/tmp/ && \
kubectl -n vault cp ./prod-internal-ip.txt vault-0:/tmp/
```

19. Включаем Kubernetes авторизацию, создаем роль и config. Путь prod-cluster

```bash
kubectl -n vault exec vault-0 -- vault auth enable -path prod-cluster kubernetes
```
```bash
kubectl -n vault exec vault-0 -- \
  vault write auth/prod-cluster/role/demo-app \
        bound_service_account_names=demo-app-sa \
        bound_service_account_namespaces=demo-app \
        policies=demo-app \
        ttl=24h
```

```bash
kubectl -n vault exec vault-0 -- \
  sh -c '
  vault write auth/prod-cluster/config \
        token_reviewer_jwt="$(cat /tmp/prod-token)" \
        kubernetes_ca_cert="$(cat /tmp/prod-CA.crt)" \
        issuer="kubernetes.default.svc" \
        kubernetes_host="$(cat /tmp/prod-internal-ip.txt):443"  '
```

19. Тестирование в Prod-cluster'е

```bash
kubectl config use-context yc-prod-cluster
```

```bash
kubectl apply -f demo-app.yaml
```

```bash
kubectl -n demo-app logs --tail=10 demo-app
```
