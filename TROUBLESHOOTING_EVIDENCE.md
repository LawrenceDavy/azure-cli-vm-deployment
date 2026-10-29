# Troubleshooting evidence and planned retests

Updated 29 October 2026. This AI-assisted evidence summary distinguishes observations reported in the existing README from **tests not run**. It does not claim fresh access to Azure, original screenshots, or independent fault-injection results.

## Documented deployment problems (historical)
**Image lookup failure.** The existing README records ResourceNotFound for Microsoft.Compute/images/UbuntuLTS while creating a VM. It says replacing the outdated UbuntuLTS alias with Ubuntu2204 allowed the deployment to proceed. The original README contains screenshots and a narrative, but no dated raw failed-and-successful command transcript here.

**VM core-quota failure.** The existing README records QuotaExceeded: the target Dsv5-family quota was 0, while the attempt required two cores. It says a quota increase was requested and Standard_D2s_v3 was used as a workaround. A fresh quota comparison and a reproducible before/after terminal log remain outstanding.

## Important automation gap
The main branch deploy-vm.sh currently has an orphaned --nsg argument on a separate line after the az vm create command. Existing draft PR #1 proposes fixing this; the PR explicitly states that passing bash -n checks syntax only and **no live Azure redeployment has been verified**. Do not call the deployment script validated. The current cleanup.sh deletes the **whole resource group**, not just the VM and not merely a deallocation.

## Planned independent fault A: NSG blocks SSH - NOT RUN
1. Use only a disposable, dedicated resource group and keep Azure Portal/CLI access for reversal.
2. Record the baseline SSH success, public-IP redaction, active NIC/subnet NSG and AllowSSH rule source, priority and port.
3. Deliberately change the test NSG rule to deny new inbound TCP/22 connections. Do not touch a shared deployment.
4. Run SSH with verbose diagnostics and a short timeout. Capture the actual connection error and rule state.
5. Compare effective security rules with the intended topology. Check source address restrictions; NSGs are stateful and existing flows may behave differently.
6. Restore the original rule, verify a **new** successful SSH connection, and record the exact rollback.

Suggested commands to adapt, not results:
    az network nsg rule list --resource-group <RG> --nsg-name <NSG> --output table
    ssh -vvv -o ConnectTimeout=8 azureuser@<REDACTED_IP>

## Planned independent fault B: wrong VM size or image - NOT RUN
Capture the precise CLI error first, then test **one** changed variable. Check quotas with:
    az vm list-usage --location <REGION> --output table
Avoid deliberately incurring quota requests or unwanted Azure charges just to generate a failure.

## Evidence to attach when genuinely performed
Date/time; VM region and SKU; architecture diagram; baseline command/result; deliberately changed setting; observed failure text; candidate causes; diagnostic output; exact fix; clean post-fix retest; any script changes; Azure billing estimate; resource-group teardown confirmation. Redact account IDs, keys and addresses.

## Interview limitations
The two historical errors are documented project experiences, not new re-runs. Passing shell syntax checks cannot establish cloud deployment success. Installing a monitoring agent does not prove working telemetry and alerts. Do not claim production engineering or validated automation from this lab.

Original evidence: [README](README.md) | [deploy script](deploy-vm.sh) | [cleanup script](cleanup.sh) | [open draft PR](../../pull/1)
