# Microsoft Azure blueprint for Zero Trust (preview)

Welcome to the Microsoft Azure blueprint for Zero Trust preview. Many of our customers in regulated industries are adopting a Zero Trust architecture, moving to a security model that more effectively adapts to the complexity of the modern environment, embraces the mobile workforce, and protects people, devices, applications, and data wherever they’re located. A Zero Trust approach should extend throughout the entire digital estate and serve as an integrated security philosophy and end-to-end strategy, across three primary principles: (1) verify explicitly, (2) enforce least privilege access, and (3) assume breach.

Using the Azure Blueprints service, the Zero Trust blueprint will first configure your VNET to deny all network traffic by default, enabling you to extend it and/or set rules for selective traffic based on your business needs. In addition, the blueprint will enforce and maintain Azure resource behaviors and configuration in compliance with specific NIST SP 800-53 security control requirements using Azure Policy. This blueprint includes Azure Resource Manager templates to deploy and configure Azure resources such as Virtual Network, Network Security Groups, Azure Key Vault, Azure Monitor, Azure Security Center, and more. If you’re working with applications that need to comply with FedRAMP High or DoD Impact Level 4 requirements or just want to improve the security posture of your cloud deployment, the blueprint for Zero Trust is designed to help you get there faster.

Please review all the artifacts and instructions carefully before importing Zero Trust blueprint into your Azure subscription. Use the supplemental, 'implementation-statements' to aid with ATO package, SSP (System Security Plan) or other relevant compliance processes. The Zero Trust blueprint is currently in preview with limited support.

[Learn more about Zero Trust](https://www.microsoft.com/en-us/security/business/zero-trust) and to learn more about how to implement Zero Trust architecture on Azure, read the [6-part blog series](https://devblogs.microsoft.com/azuregov/implementing-zero-trust-with-microsoft-azure-identity-and-access-management-1-of-6/) on the Azure Government Dev Blog.

For more information, questions, or feedback please [contact us](https://aka.ms/zerotrust-blueprint-feedback).

## Contents

| File/folder       | Description                                |
|-------------------|--------------------------------------------|
| `automation/zero-trust-architecture`      | Zero Trust blueprint sample and associated artifacts.                        |
| `automation/zero-trust-architecture-offline`      | Zero Trust blueprint sample and associated artifacts for offline (disconnected from internet) environment.
| `automation/zero-trust-architecture-offline-v2`      | Zero Trust blueprint sample and associated artifacts for offline (disconnected from internet) environment. This has hub/spoke architecture.                    |
| `implementation-statements`      | Implementation statements, mapped to NIST security controls, describing the implementation deployed and configured by the automation to aid with compliance ATO process.                         |
| `utils`      | General tools and utilities to assist with automation and implementation statements.                         |
| `README.md`       | This README file.                          |
| `CONTRIBUTING.md` | Guidelines for contributing to the sample. |
| `LICENSE`         | The license for the sample.                |

## Prerequisites

1. An active Azure or Azure Government subscription. [Start here](https://azure.microsoft.com/en-us/)

## Instructions

1. [Zero Trust blueprint](/automation/zero-trust-architecture/README.md)
2. [Zero Trust blueprint (offline)](/automation/zero-trust-architecture-offline/README.md)
3. [Zero Trust blueprint (offline) v2](/automation/zero-trust-architecture-offline-v2/README.md)
4. [Implementation statements](/implementation-statements/README.md)
    * [VSCode extension](/utils/authoring-assistant/README.md)

## Feedback

For more information, questions, or feedback please [contact us](https://aka.ms/zerotrust-blueprint-feedback).

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
