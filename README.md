# Azure Landing Zone - Terraform Automation

Kompletna automatyzacja Azure Landing Zone w Terraform, zgodna z najlepszymi praktykami Microsoft Cloud Adoption Framework (CAF).

## Spis Treści

- [Architektura](#architektura)
- [Moduły](#moduły)
- [Wymagania](#wymagania)
- [Szybki Start](#szybki-start)
- [Konfiguracja](#konfiguracja)
- [Wdrożenie](#wdrożenie)
- [Struktura Projektu](#struktura-projektu)
- [Najlepsze Praktyki](#najlepsze-praktyki)
- [Troubleshooting](#troubleshooting)

## Architektura

To rozwiązanie implementuje kompletną Azure Landing Zone z następującymi komponentami:

### 1. Management Groups (Grupy Zarządzania)
```
Root
├── Platform
│   ├── Management
│   ├── Connectivity
│   └── Identity
├── Landing Zones
│   ├── Production
│   └── Development
├── Sandbox
└── Decommissioned
```

### 2. Network (Hub-Spoke)
- **Hub VNet**: Centralna sieć z podsieciami dla:
  - Azure Firewall
  - VPN Gateway
  - Azure Bastion
  - Shared Services
- **Spoke VNets**: Sieci dla środowisk (Production, Development)
- VNet Peering między Hub a Spoke
- Network Security Groups (NSG)

### 3. Security & Monitoring
- Log Analytics Workspace
- Azure Security Center (Defender for Cloud)
- Azure Monitor z Action Groups
- Activity Log Alerts
- Diagnostic Settings

### 4. Policy & Governance
- Custom Policy Definitions
- Policy Assignments
- Policy Initiatives
- Built-in Policies

### 5. Identity & Access Management
- Custom Role Definitions
- RBAC Assignments
- Azure AD Groups (opcjonalnie)

### 6. Shared Services
- Azure Key Vault
- Storage Account (z kontenerami dla Terraform State, Flow Logs, Boot Diagnostics)
- Automation Account
- Recovery Services Vault z politykami backup

## Moduły

| Moduł | Opis | Zasoby |
|-------|------|---------|
| `management-groups` | Hierarchia grup zarządzania | Management Groups |
| `network` | Topologia Hub-Spoke | VNets, Subnets, Peering, NSG, Bastion |
| `policy` | Azure Policies i governance | Policy Definitions, Assignments, Initiatives |
| `security-monitoring` | Bezpieczeństwo i monitoring | Log Analytics, Security Center, Alerts |
| `iam` | Zarządzanie tożsamością i dostępem | Custom Roles, RBAC, AD Groups |
| `shared-services` | Usługi współdzielone | Key Vault, Storage, Automation, Backup |

## Wymagania

### Narzędzia
- Terraform >= 1.5.0
- Azure CLI >= 2.50.0
- Uprawnienia Azure:
  - Owner lub User Access Administrator na poziomie subskrypcji
  - Uprawnienia do tworzenia Management Groups
  - Azure AD permissions (jeśli tworzysz grupy AD)

### Providers
- `hashicorp/azurerm` ~> 3.80
- `hashicorp/azuread` ~> 2.45

## Szybki Start

### 1. Zaloguj się do Azure
```bash
az login
az account set --subscription "<your-subscription-id>"
```

### 2. Sklonuj repozytorium
```bash
git clone <repository-url>
cd tera_auto
```

### 3. Przygotuj konfigurację
```bash
cp terraform.tfvars.example terraform.tfvars
```

Edytuj `terraform.tfvars` i dostosuj wartości do swoich potrzeb:
```hcl
organization_name = "MyCompany"
location          = "westeurope"
# ... inne parametry
```

### 4. Inicjalizuj Terraform
```bash
terraform init
```

### 5. Sprawdź plan
```bash
terraform plan
```

### 6. Wdróż Landing Zone
```bash
terraform apply
```

## Konfiguracja

### Minimalna Konfiguracja

Plik `terraform.tfvars`:
```hcl
organization_name = "MyOrg"
location         = "westeurope"
```

### Pełna Konfiguracja

Zobacz `terraform.tfvars.example` dla wszystkich dostępnych opcji.

### Ważne Zmienne

| Zmienna | Opis | Domyślna Wartość |
|---------|------|------------------|
| `organization_name` | Nazwa organizacji (używana w nazwach zasobów) | - |
| `location` | Region Azure | `westeurope` |
| `hub_vnet_config` | Konfiguracja sieci Hub | Zobacz przykład |
| `spoke_vnets` | Konfiguracja sieci Spoke | Zobacz przykład |
| `enable_security_center` | Włącz Azure Security Center | `true` |
| `security_center_tier` | Tier Security Center (`Free`/`Standard`) | `Standard` |

## Wdrożenie

### Krok po kroku

#### 1. Management Groups
```bash
terraform apply -target=module.management_groups
```

#### 2. Network Infrastructure
```bash
terraform apply -target=module.network
```

#### 3. Policy & Governance
```bash
terraform apply -target=module.policy
```

#### 4. Security & Monitoring
```bash
terraform apply -target=module.security_monitoring
```

#### 5. IAM
```bash
terraform apply -target=module.iam
```

#### 6. Shared Services
```bash
terraform apply -target=module.shared_services
```

Lub wdróż wszystko naraz:
```bash
terraform apply
```

### Remote State

Aby przechowywać stan Terraform w Azure Storage, odkomentuj backend w `main.tf`:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "sttfstate"
    container_name       = "tfstate"
    key                  = "landing-zone.tfstate"
  }
}
```

Najpierw utwórz infrastrukturę dla state:
```bash
# Utwórz resource group
az group create --name rg-terraform-state --location westeurope

# Utwórz storage account
az storage account create \
  --name sttfstate \
  --resource-group rg-terraform-state \
  --location westeurope \
  --sku Standard_LRS

# Utwórz container
az storage container create \
  --name tfstate \
  --account-name sttfstate
```

## Struktura Projektu

```
.
├── main.tf                          # Główna konfiguracja
├── variables.tf                     # Deklaracje zmiennych
├── outputs.tf                       # Outputs
├── terraform.tfvars.example         # Przykładowa konfiguracja
├── README.md                        # Ta dokumentacja
├── docs/                            # Dodatkowa dokumentacja
│   ├── ARCHITECTURE.md             # Szczegóły architektury
│   ├── NETWORK.md                  # Dokumentacja sieci
│   └── SECURITY.md                 # Polityki bezpieczeństwa
└── modules/
    ├── management-groups/           # Moduł Management Groups
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── network/                     # Moduł Network
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── policy/                      # Moduł Policy
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── security-monitoring/         # Moduł Security & Monitoring
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── iam/                         # Moduł IAM
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── shared-services/             # Moduł Shared Services
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Najlepsze Praktyki

### Security
1. **Network Segmentation**: Używaj NSG do kontroli ruchu
2. **Encryption**: Wymuszaj HTTPS i encryption at rest
3. **Least Privilege**: Używaj RBAC z minimalnymi uprawnieniami
4. **Monitoring**: Włącz Azure Security Center Standard tier
5. **Key Management**: Przechowuj sekrety w Key Vault

### Naming Conventions
Wykorzystywane są standardy Microsoft CAF:
- Resource Groups: `rg-{purpose}-{env}`
- VNets: `vnet-{purpose}-{env}`
- Subnets: `snet-{purpose}`
- Storage: `st{purpose}{uniqueid}`
- Key Vault: `kv-{purpose}`

### Tagging
Wymagane tagi (wymuszane przez Policy):
- `Environment`: Production/Development/Staging
- `Owner`: Właściciel zasobu
- `Project`: Nazwa projektu
- `ManagedBy`: Terraform

### Cost Optimization
1. Używaj `Free` tier dla Security Center w środowisku dev
2. Wyłącz DDoS Protection Plan jeśli nie jest wymagany
3. Wybierz odpowiedni replication tier dla Storage (LRS vs GRS)
4. Monitoruj koszty przez Azure Cost Management

## Outputs

Po wdrożeniu dostępne są następujące outputs:

```bash
terraform output
```

### Ważne Outputs
- `management_groups`: ID grup zarządzania
- `network`: ID VNetów i Subnetów
- `log_analytics_workspace`: Workspace ID (sensitive)
- `key_vault`: Key Vault URI i ID
- `resource_groups`: Nazwy utworzonych Resource Groups

### Przykład użycia outputs
```bash
# Pobierz Key Vault URI
terraform output -json key_vault | jq -r '.uri'

# Pobierz ID Hub VNet
terraform output -json network | jq -r '.hub_vnet_id'
```

## Troubleshooting

### Problem: Management Group permissions
**Błąd**: "Insufficient privileges to complete the operation"

**Rozwiązanie**: Upewnij się, że masz uprawnienia `Management Group Contributor` lub wyższe.

```bash
az role assignment create \
  --assignee <your-user-id> \
  --role "Management Group Contributor" \
  --scope /providers/Microsoft.Management/managementGroups/<mg-id>
```

### Problem: Policy assignments fail
**Błąd**: Policy assignment requires managed identity

**Rozwiązanie**: Upewnij się, że policy assignments mają ustawioną managed identity i odpowiednie uprawnienia.

### Problem: Key Vault access denied
**Błąd**: "The client does not have sufficient permissions"

**Rozwiązanie**: Moduł używa RBAC dla Key Vault. Przypisz odpowiednią rolę:

```bash
az role assignment create \
  --role "Key Vault Administrator" \
  --assignee <your-user-id> \
  --scope /subscriptions/<sub-id>/resourceGroups/<rg-name>/providers/Microsoft.KeyVault/vaults/<kv-name>
```

### Problem: Network peering fails
**Błąd**: Peering cannot be established

**Rozwiązanie**: Sprawdź, czy address spaces VNetów się nie nakładają i czy VNety są w tym samym regionie (lub mają włączone global peering).

## Maintenance

### Aktualizacja Resources
```bash
terraform plan
terraform apply
```

### Dodanie nowego Spoke VNet
Edytuj `terraform.tfvars`:
```hcl
spoke_vnets = {
  production = { ... }
  development = { ... }
  staging = {
    name          = "vnet-spoke-staging"
    address_space = ["10.3.0.0/16"]
    subnets = {
      web = {
        address_prefix = "10.3.1.0/24"
      }
    }
  }
}
```

Następnie:
```bash
terraform apply
```

### Usuwanie zasobów
⚠️ **UWAGA**: Usuwanie Landing Zone usunie wszystkie zasoby!

```bash
terraform destroy
```

## Contributing

1. Utwórz feature branch
2. Wprowadź zmiany
3. Przetestuj z `terraform plan`
4. Utwórz Pull Request

## License

MIT License - zobacz LICENSE dla szczegółów

## Support

Dla wsparcia i pytań:
- Utwórz Issue w repozytorium
- Sprawdź dokumentację Azure CAF: https://docs.microsoft.com/azure/cloud-adoption-framework/

## Zasoby

- [Azure Cloud Adoption Framework](https://docs.microsoft.com/azure/cloud-adoption-framework/)
- [Azure Landing Zones](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Naming Convention](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
