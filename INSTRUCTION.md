# Controlling Scheduling: пояснення і перевірка

Ця інструкція допомагає самостійно виконати завдання з керування розміщенням
Pods. Вона пояснює потрібні правила та показує, як довести, що scheduler виконує
їх правильно.

## ELI5: чотири різні механізми

- **Label** — наліпка на Node, наприклад `app=mysql`.
- **Taint** — охоронець біля Node. `app=mysql:NoSchedule` не пускає нові Pods,
  які не мають відповідного toleration.
- **Toleration** — перепустка через охоронця. Вона дозволяє Pod потрапити на
  tainted Node, але сама не змушує scheduler вибрати саме цей Node.
- **Node affinity** — правило вибору Node за його labels.
- **Pod anti-affinity** — правило «не селити два однакові Pods на одному Node».

Для MySQL потрібні одночасно:

```text
taint + toleration + required node affinity + required pod anti-affinity
```

Для Django потрібні:

```text
preferred node affinity + required pod anti-affinity
```

`IgnoredDuringExecution` означає: правило перевіряється під час scheduling, але
вже запущений Pod автоматично не виселяється, якщо label Node пізніше зміниться.

## 1. Створити правильний kind-кластер

Запускай команди з кореня репозиторію:

```bash
cd /Users/a.majlo/Mate/Kuber/devops_todolist_kubernetes_task_11_controlling_scheduling
kind create cluster --name todo-cluster --config cluster.yml
```

Якщо кластер із таким ім'ям уже існує, спочатку виріши, чи можна видалити його.
Наступна команда видаляє весь навчальний кластер разом із даними:

```bash
kind delete cluster --name todo-cluster
```

Після створення перевір:

```bash
kind get nodes --name todo-cluster
kubectl get nodes -L app
```

Поточний `cluster.yml` описує **7 Nodes**:

- один control-plane;
- два workers із `app=mysql`;
- три workers із `app=todoapp`;
- один worker без label `app`.

Якщо `kind get nodes` показує лише один control-plane, кластер створено без
`--config cluster.yml`. Label вручну не виправить відсутні workers — кластер
потрібно пересоздати правильно.

## 2. Переглянути Labels і Taints

```bash
kubectl get nodes --show-labels
kubectl get nodes -L app
kubectl describe nodes
```

Зручно окремо знайти MySQL Nodes:

```bash
kubectl get nodes -l app=mysql
```

До додавання taint колонка `TAINTS` може бути порожньою або містити системний
taint control-plane. Це нормально.

## 3. Додати taint для MySQL Nodes

Команда з label selector змінить тільки Nodes із `app=mysql`:

```bash
kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite
```

Цю саму команду потрібно додати в `bootstrap.sh` **до застосування MySQL
StatefulSet**, щоб нові MySQL Pods одразу перевіряли toleration.

Перевір taints:

```bash
kubectl get nodes -l app=mysql \
  -o custom-columns='NAME:.metadata.name,TAINTS:.spec.taints'
```

Очікуй `key: app`, `value: mysql`, `effect: NoSchedule` на обох MySQL Nodes.

Видалення цього taint, якщо треба почати тест заново:

```bash
kubectl taint nodes -l app=mysql app=mysql:NoSchedule-
```

Мінус наприкінці означає «видалити taint».

## 4. StatefulSet: Toleration

У `.infrastructure/mysql/statefulSet.yml` блок додається в
`spec.template.spec`, на одному рівні з `containers`, `volumes` і `affinity`:

```yaml
tolerations:
  - key: app
    operator: Equal
    value: mysql
    effect: NoSchedule
```

Без toleration MySQL Pods отримають `Pending`, тому що taint забороняє
scheduling. Toleration лише дозволяє використовувати MySQL Nodes; потрібний Node
вибирає наступне правило.

## 5. StatefulSet: required Node Affinity

Також у `spec.template.spec`:

```yaml
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
        - matchExpressions:
            - key: app
              operator: In
              values:
                - mysql
```

`required...` — жорстка вимога. MySQL Pod не запуститься на Node без
`app=mysql`, навіть якщо інші Nodes мають вільні ресурси.

## 6. StatefulSet: required Pod Anti-Affinity

Додай `podAntiAffinity` всередину того самого `affinity`:

```yaml
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
        - matchExpressions:
            - key: app
              operator: In
              values:
                - mysql
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
            - key: app
              operator: In
              values:
                - mysql
        topologyKey: kubernetes.io/hostname
```

`labelSelector` шукає інші Pods із `app=mysql`. `topologyKey` порівнює hostname
Nodes. Результат: два MySQL Pods не можуть жити на одному Node.

У кластері лише два Nodes із `app=mysql`, тому при `replicas: 2` кожен MySQL Pod
має опинитися на окремому MySQL Node.

## 7. Deployment: preferred Node Affinity

У `.infrastructure/app/deployment.yml` блок також додається в
`spec.template.spec`:

```yaml
affinity:
  nodeAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        preference:
          matchExpressions:
            - key: app
              operator: In
              values:
                - todoapp
```

Правильне Kubernetes-поле пишеться `preferred`, хоча в README є друкарська
помилка `Prefered`.

`preferred...` — побажання, а не заборона. Scheduler спочатку шукає Nodes із
`app=todoapp`, але за потреби має право використати інший Node. `weight: 100` —
максимальна вага цієї переваги.

## 8. Deployment: required Pod Anti-Affinity

Додай до того самого `affinity`:

```yaml
affinity:
  nodeAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        preference:
          matchExpressions:
            - key: app
              operator: In
              values:
                - todoapp
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
            - key: app
              operator: In
              values:
                - todoapp
        topologyKey: kubernetes.io/hostname
```

Це забороняє розміщувати два Django Pods на одному hostname. Selector працює,
бо Pod template Deployment уже має label `app: todoapp`.

## 9. Що має містити bootstrap.sh

Логічний порядок:

1. перевірити/додати taint на Nodes із `app=mysql`;
2. створити namespace та конфігурацію MySQL;
3. застосувати Service і StatefulSet;
4. створити namespace та ресурси Django;
5. застосувати Deployment, Services та інші ресурси попередніх завдань;
6. за потреби встановити Ingress controller й застосувати Ingress;
7. дочекатися rollout ключових workloads.

Мінімальна обов'язкова команда для цього завдання:

```bash
kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite
```

Для передбачуваної перевірки корисно наприкінці чекати:

```bash
kubectl rollout status statefulset/mysql --namespace mysql --timeout=300s
kubectl rollout status deployment/todoapp --namespace todoapp --timeout=300s
```

## 10. Статична перевірка перед запуском

```bash
bash -n bootstrap.sh
git diff --check
kubectl create --dry-run=client --validate=false -R -f .infrastructure
```

Якщо кластер уже працює, зроби також server-side validation:

```bash
kubectl apply --dry-run=server -R -f .infrastructure
```

Dry-run перевіряє структуру YAML та Kubernetes schema, але не доводить, що
scheduler зможе знайти потрібні Nodes. Це перевіряється після запуску.

## 11. Розгорнути ресурси

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

Потім:

```bash
kubectl get pods -A -o wide
kubectl get events -A --sort-by=.lastTimestamp
```

## 12. Перевірити MySQL scheduling

```bash
kubectl get pods -n mysql -l app=mysql \
  -o custom-columns='POD:.metadata.name,NODE:.spec.nodeName,STATUS:.status.phase'

kubectl get nodes -L app
```

Очікування:

- обидва MySQL Pods — `Running`;
- кожен запущений на Node із `app=mysql`;
- імена Nodes у двох рядках різні.

Перевір, що Pod отримав toleration та affinity:

```bash
kubectl get statefulset mysql -n mysql -o yaml
kubectl describe pod mysql-0 -n mysql
```

## 13. Перевірити Django scheduling

```bash
kubectl get pods -n todoapp -l app=todoapp \
  -o custom-columns='POD:.metadata.name,NODE:.spec.nodeName,STATUS:.status.phase'

kubectl get nodes -L app
```

Очікування:

- Django Pods працюють на різних Nodes;
- scheduler віддає перевагу Nodes із `app=todoapp`;
- на MySQL Nodes вони не потрапляють через `app=mysql:NoSchedule`, бо не мають
  MySQL toleration.

Node affinity для Django є preferred, тому сам по собі Pod на іншому
незатейнченому Node не означає помилку. Жорсткою вимогою тут є anti-affinity.

## 14. Негативний тест MySQL anti-affinity (необов'язковий)

У кластері два MySQL Nodes. Тимчасово попроси третю репліку:

```bash
kubectl scale statefulset mysql --namespace mysql --replicas=3
kubectl get pods -n mysql -o wide --watch
```

Очікування: `mysql-2` залишиться `Pending`, бо:

- node affinity дозволяє лише два Nodes із `app=mysql`;
- pod anti-affinity уже зайняла кожен із них одним MySQL Pod.

Подивись пояснення scheduler:

```bash
kubectl describe pod mysql-2 --namespace mysql
```

В `Events` має бути причина, пов'язана з pod anti-affinity або відсутністю
придатних Nodes.

Обов'язково поверни початковий стан:

```bash
kubectl scale statefulset mysql --namespace mysql --replicas=2
```

## 15. Негативний тест taint (необов'язковий)

Створи тимчасовий Pod із nodeSelector `app=mysql`, але без toleration:

```bash
kubectl run taint-test \
  --image=busybox:1.36 \
  --restart=Never \
  --overrides='{"spec":{"nodeSelector":{"app":"mysql"}}}' \
  -- sleep 300
```

Він має залишитися `Pending`:

```bash
kubectl get pod taint-test -o wide
kubectl describe pod taint-test
```

В Events очікуй повідомлення про `untolerated taint {app: mysql}`.

Прибери тестовий Pod:

```bash
kubectl delete pod taint-test
```

## 16. Типові проблеми

### `0/N nodes are available: untolerated taint`

Pod не має toleration або toleration не збігається за `key`, `value`, `effect`.

### `node(s) didn't match Pod's node affinity/selector`

На Nodes немає потрібного label або в affinity помилково вказані key/value.

```bash
kubectl get nodes -L app
```

### `node(s) didn't match pod anti-affinity rules`

На кожному дозволеному Node уже є Pod із label, який збігається з
`labelSelector`. Перевір кількість Nodes і replicas.

### Pods опинилися на одному Node

Перевір:

- використано `requiredDuringSchedulingIgnoredDuringExecution`, а не preferred;
- `topologyKey` дорівнює `kubernetes.io/hostname`;
- selector anti-affinity збігається з labels у `spec.template.metadata.labels`;
- anti-affinity знаходиться в `spec.template.spec.affinity`, а не у верхньому
  `spec` StatefulSet/Deployment.

### Є лише один Node без labels

Кластер створено без `cluster.yml`. Пересоздай його командою з `--config`.

## 17. Підготовка Git і Pull Request

Переглянь зміни:

```bash
git status
git diff
```

Додавай конкретні файли, а не все без перевірки:

```bash
git add bootstrap.sh
git add .infrastructure/mysql/statefulSet.yml
git add .infrastructure/app/deployment.yml
git add INSTRUCTION.md
```

Якщо ти змінював `cluster.yml`, додай і його:

```bash
git add cluster.yml
```

Перевір майбутній commit:

```bash
git diff --cached
git status
```

Створи commit і відправ гілку:

```bash
git commit -m "Configure Kubernetes pod scheduling rules"
git push -u origin "$(git branch --show-current)"
```

Після push створи Pull Request зі своєї гілки у `mate-academy:main` і лише тоді
прикріплюй PR до завдання на платформі.
