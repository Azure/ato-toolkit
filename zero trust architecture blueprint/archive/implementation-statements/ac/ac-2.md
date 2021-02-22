---
Title: AC-02 FedRAMP Control Enhancement
ResponsibleRole:  Org. Roles
---
## Implementation Status (check all that apply)

* [x] Implemented
* [ ] Partially implemented
* [ ] Planned
* [ ] Alternative implementation
* [ ] Not applicable

---

## Control Origination (check all that apply)

* [ ] Service Provider Corporate
* [x] Service Provider System Specific
* [ ] Service Provider Hybrid (Corporate and System Specific)
* [ ] Configured by Customer (Customer System Specific)
* [ ] Provided by Customer (Customer System Specific)
* [x] Shared (Service Provider and Customer Responsibility)
* [ ] Inherited from pre-existing FedRAMP Authorization

---

## Control Description

The organization:

a. Identifies and selects the following types of information system accounts to support organizational missions/business functions: [Assignment: organization-defined information system account types];

b. Assigns account managers for information system accounts;

c. Establishes conditions for group and role membership;

d. Specifies authorized users of the information system, group and role membership, and access authorizations (i.e., privileges) and other attributes (as required) for each account;

e. Requires approvals by [Assignment: organization-defined personnel or roles] for requests to create information system accounts;

f. Creates, enables, modifies, disables, and removes information system accounts in accordance with [Assignment: organization-defined procedures or conditions];

g. Monitors the use of information system accounts;

h. Notifies account managers:

1. When accounts are no longer required;

2. When users are terminated or transferred; and

3. When individual information system usage or need-to-know changes;

i. Authorizes access to the information system based on:

1. A valid access authorization;

2. Intended system usage; and

3. Other attributes as required by the organization or associated missions/business functions;

j. Reviews accounts for compliance with account management requirements [Assignment: organization-defined frequency]; and

k. Establishes a process for reissuing shared/group account credentials (if deployed) when individuals are removed from the group.

### Org. Shared Responsibilities Guidance

All customers should review their Customer Responsibilities requirements as documented in Microsoft Azure SSPs. Customers are responsible for implementation and documentation of controls not inherited directly from Microsoft. This includes all controls where a Shared or Customer provided responsibility is defined by Microsoft Azure.

If Org. enables relevant Azure policies to implement this control, Org. is still responsible for providing the following capabilities:

1. Identification and selection of all Org. controlled accounts within the system;(AC-2.a)
2. Identification and assignment of Org. account managers;(AC-2.b)
3. Establishing role and group membership criteria for Org.-controlled account types; (AC-2.c)
4. Process to define how Authorized users are specified and privilege levels are determined; (AC-2.d)
5. Process to require ISSM or ISSO to approve the creation of new accounts for the system; (AC-2.e)
6. Definition of account management process lifecycle from creation to disablement/removal; (AC-2.f)
7. Monitoring the use of all customer-controlled accounts;(AC-2.g)
8. Notification process to Org. account managers for all controlled account changes;(AC-2.h)
9. Process to grant Org. controlled accounts with valid authorizations;(AC-2.i)
10. Review accounts for compliance with account management requirements on a monthly basis for privileged access and every six months for non-privileged access;(AC-2.j)
11. Process to manage Org.-controlled shared/group account credentials;;(AC-2.k)

Org. should clearly document in the section below how it implements controls requirements.

## Part a

### Implementation Statement

Org.  is responsible for identifying all customer-controlled accounts within the system.

Access control for Hosted Services and Storage accounts is governed by the subscription. The ability to authenticate with the Org.  Federated Identities associated with the subscription grants full control to all of the Hosted Services and Storage accounts within that subscription. Org. has defined various account types, roles and organized them.  Org. also manages resources that are configured and operating independent of the underlying Azure services. These privileged functions are fully defined and documented.

TODO: Optional placeholder for non Azure, OSS or custom implementations

Org. implements various Azure services to meet this control requirement such as _________________.

Org. implements various Azure services to meet this control requirement such as Azure Active Directory (AAD).  Org. uses AAD to manage access to implement Role-Based Access Control (RBAC).

### Org. Planned Controls

TODO: Fill this out as needed or remove the section

### Org.'s Customer Responsibility

TODO: Fill this out as needed or remove the section

## Part b

### Implementation Statement

Org. is responsible for assignment of Org. account managers.

Org.  Global admins assign other admin roles, and only global admins can manage the accounts of other global admins. Org.  Administrators can create users accounts into roles or classes of account types including account managers.

TODO: Optional placeholder for non Azure, OSS or custom implementations

Org. implements various Azure services to meet this control requirement such as _________________.

### Org. Planned Controls

TODO: Fill this out as needed or remove the section

### Org.'s Customer Responsibility

TODO: Fill this out as needed or remove the section

## Part c

### Implementation Statement

Org. is responsible for establishing role and group membership criteria for Org.-controlled account types.

Org. Administrators can create users accounts into roles or classes of account types. As needs arise, and under appropriate change management mechanisms, actions to modify and disable and remove accounts can take enforced to ensure account management requirements are met.

The conditions for group and role membership are dictated by the functions of the account holder’s role and managed by the data or system owner to ensure privileges and functions are commensurate with business needs. Org. deployed and controlled user accounts, Org.  implements ____________________.

TODO: Optional placeholder for non Azure, OSS or custom implementations

Org. implements various Azure services to meet this control requirement such as _________________.

Org. uses underlying Azure services, such as Azure AD (AAD), to implement role and group memberships/assignments for information system accounts.

### Org. Planned Controls

TODO: Fill this out as needed or remove the section

### Org.'s Customer Responsibility

TODO: Fill this out as needed or remove the section

## Part d

### Implementation Statement

Org. is responsible for the process to define how Authorized users are specified and how privilege levels are determined across all Org. managed accounts.

Org. deploys user accounts on Org.-managed user accounts and implements ____________________.

TODO: Optional placeholder for non Azure, OSS or custom implementations

Org. implements various Azure services to meet this control requirement such as _________________.

Org. uses pre-determined users and privilege information and leverage underlying Azure services to implement role and group memberships for users. Org. leverages Azure AD (AAD) to perform user Role-Based Access Control (RBAC) to identify and control the access privileges of each service team personnel. Access privileges vary depending on the role.

### Org. Planned Controls

TODO: Fill this out as needed or remove the section

### Org.'s Customer Responsibility

TODO: Fill this out as needed or remove the section

## Part e

### Implementation Statement

Org. is responsible for the process to require the ISSM or ISSO to approve the creation of new accounts for the system.

All Org. admins are responsible for requiring appropriate approvals for requests to establish organizational accounts in compliance with Org. policy.  If service team personnel need additional access to the production environment, they request that access and provide business justifications. Service team personnel with the access approver role then review and approve/deny the type of access requested. Access is only provided for a finite period of time based on the expected duration of the work to be performed. If access is approved, service team personnel are assigned with the minimum permissions required to perform the work and automatically revokes permissions at the end of the specified time period.

TODO: Optional placeholder for non Azure, OSS or custom implementations

Org. implements various Azure services to meet this control requirement such as _________________.

Org. leverages Azure AD (AAD) Privileged Identity Management (PIM). With Azure AD (AAD)  Org.  can configure roles to require approval for activation and choose one or multiple users or groups as delegated approvers (ISSM or ISSO).

### Org. Planned Controls

TODO: Fill this out as needed or remove the section

### Org.'s Customer Responsibility

TODO: Fill this out as needed or remove the section

## Part f

### Implementation Statement

Org. is responsible for the definition of an account management process lifecycle from creation to disablement/removal.

Org. defines various account types/roles and organizes them to support organizational access activities. Org. defines and implements a process in place for account management of their users by creating new user accounts for new employees, modifying access in accordance with changes to employee job responsibilities, and disabling the accounts of terminated employees. The processes should be automatically audited and notifications should be sent to appropriate individuals as required for all Org. managed accounts.

TODO: Optional placeholder for non Azure, OSS or custom implementations

Org. implements various Azure services to meet this control requirement such as _________________.

Org. leverages Azure Policy. Azure Policy assigns Azure Policy definitions that audit external accounts with read, write, and owner permissions on a subscription and to deprecated accounts. By reviewing the accounts audited by these policies, Org. Administrators can create users accounts into roles or classes of account types. As needs arise, and under appropriate change management mechanisms, actions to modify and disable and remove accounts can take enforced to ensure account management requirements are met.

### Org. Planned Controls

TODO: Fill this out as needed or remove the section

### Org.'s Customer Responsibility

TODO: Fill this out as needed or remove the section

## Part g

### Implementation Statement

Org. is responsible for definition of account management process lifecycle from creation to disablement/removal.

Org. defines various account types/roles and organizes them to support organizational access activities. Org. defines and implements a process in place for account management of their users by creating new user accounts for new employees, modifying access in accordance with changes to employee job responsibilities, and disabling the accounts of terminated employees. The processes are automatically audited, and notifications are sent to appropriate individuals as required for all Org. managed accounts.

TODO: Optional placeholder for non Azure, OSS or custom implementations

Org. implements various Azure services to meet this control requirement such as _________________.

Org. leverages Azure Policy. Azure Policy assigns Azure Policy definitions that monitor External accounts with read, write, and owner permissions on a subscription and Deprecated accounts. By reviewing the accounts audited by these policies, Org. Administrators create users accounts into roles or classes of account types. As needs arise, and under appropriate change management mechanisms, actions to modify and disable and remove accounts are taken to ensure account management requirements are met.

### Org. Planned Controls

TODO: Fill this out as needed or remove the section

### Org.'s Customer Responsibility

TODO: Fill this out as needed or remove the section

## Part h

### Implementation Statement

Org. is responsible for notifying account managers (defined in AC-02.b) of all customer-controlled accounts when users are terminated or transferred, accounts are no longer required, or system usage or need-to-know changes.

Org. user accounts changes should be monitored notifications should be sent to appropriate individuals as required for all Org. managed accounts.

TODO: Optional placeholder for non Azure, OSS or custom implementations

Org. implements various Azure services to meet this control requirement such as _________________.

### Org. Planned Controls

TODO: Fill this out as needed or remove the section

### Org.'s Customer Responsibility

TODO: Fill this out as needed or remove the section

## Part i

### Implementation Statement

Org. is responsible for the process to grant Org. controlled accounts with valid authorizations.  Information system usage or need-to-know/ need-to-share changes are managed by the Org.. Org. Managers validate whether the user requires access to the production environment (or privileged role) to fulfill their duties and support the information system. Access is granted based on this valid access authorization and documented intended systems usage consistent with the permission type and conditions for group membership and on RBAC principles.

TODO: Optional placeholder for non Azure, OSS or custom implementations

Org. implements various Azure services to meet this control requirement such as _________________.

Org. uses underlying Azure services to provision access to users using Azure AD (AAD). Org. leverages Azure Active Directory app provisioning to create and manage user identities in the SaaS applications.

### Org. Planned Controls

TODO: Fill this out as needed or remove the section

### Org.'s Customer Responsibility

TODO: Fill this out as needed or remove the section

## Part j

### Implementation Statement

Org. is responsible for reviewing privileged accounts at least monthly and non-privileged accounts every 6 months to ensure compliance with the applicable account requirements. If an individual is identified as having access to a higher privileged role, the reviewing team is responsible to identify the role the User needs to be transitioned to and communicate (via the ticketing system/email) to appropriate account managers the change that needs to be executed.

TODO: Optional placeholder for non Azure, OSS or custom implementations

Org. implements various Azure services to meet this control requirement such as _________________.

Org. leverages Azure Policy to review accounts and corresponding privileges assigned by Azure AD (AAD).  Reviewing role assignments for users in AAD using Azure Policy allows deprecated accounts (with/without owner permissions) and external accounts to be removed the subscription.

### Org. Planned Controls

TODO: Fill this out as needed or remove the section

### Org.'s Customer Responsibility

TODO: Fill this out as needed or remove the section

## Part k

### Implementation Statement

Org.  is responsible to establish processes around re-issuing of shared/group account credentials if they are being utilized within the environment when individuals are removed from the group.

TODO: Optional placeholder for non Azure, OSS or custom implementations

Org. implements various Azure services to meet this control requirement such as _________________.

Org. leverages underlying Azure services to re-issue credentials for shared/group accounts when an individual leaves the group, using Azure AD (AAD) and Privileged Identity Management (PIM). Org. manages credentials for all user accounts including shared/group accounts using AAD.

### Org. Planned Controls

TODO: Fill this out as needed or remove the section

### Org.'s Customer Responsibility

TODO: Fill this out as needed or remove the section
