# Oracle Always Free — consulta em 30/10/2026

## Limites oficiais relevantes

- **Ampere A1:** 1.500 OCPU-h e 9.000 GB-h/mês; para tenancy Always Free, **2 OCPUs e 12 GB de memória no total**. Pode ser uma VM de 2 OCPUs ou duas de 1 OCPU. Compute deve estar na **home region**. [Oracle: Always Free Resources](https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm)
- **Discos:** 200 GB somando boot volumes e block volumes; cinco backups de volumes, também somados. A franquia vale na home region. Volumes antigos preservados consomem capacidade. [Oracle: Always Free Resources](https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm)
- **Rede:** uma instância Network Load Balancer no Always Free; até duas VCNs na tenancy gratuita. [Oracle: Always Free Resources](https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm)
- **Tenancy paga:** a tabela de preços ainda descreve 3.000 OCPU-h/18.000 GB-h gratuitos para A1 em *paid tenancies*. Isso não muda o objetivo deste projeto de respeitar o limite menor de 2 OCPUs/12 GB. [Oracle: OCI Price List, Containers and Functions](https://www.oracle.com/cloud/price-list/)
- **Tráfego:** entrada gratuita; saída originada na América do Sul tem os primeiros 10 TB/mês gratuitos. NLB aparece como gratuito na tabela de preços. [Oracle: OCI Price List, Networking](https://www.oracle.com/cloud/price-list/)

## Aplicação ao projeto — inferências da configuração local

O desenho anterior de um servidor e um worker, cada um com 2 OCPUs/12 GB,
somava 4 OCPUs/24 GB. Para reduzir as máquinas pela metade, o desenho
compatível é **um servidor K3s `VM.Standard.A1.Flex` com 2 OCPUs, 12 GB e
boot de 100 GB; zero workers**. Em um mês de 744 horas, equivale a
1.488 OCPU-h e 8.928 GB-h, abaixo das franquias mensais publicadas.

Isso pressupõe que outras instâncias A1 e outros discos da tenancy não
estejam usando a mesma franquia. States vazios do Terraform não provam
ausência de recursos fora desses states. `sa-vinhedo-1` só satisfaz a regra
regional se for a home region da conta.

Em uma única máquina, Longhorn, PostgreSQL e gateway precisam de uma réplica
ou de regras de agendamento que aceitem um único nó. Isso elimina a
redundância entre máquinas. A observabilidade deve ser desativada por
comentários nos manifests de entrada, preservando seus arquivos para
reativação, conforme pedido do usuário.

## Gateways e desempenho de disco

`infra/modules/vcn/main.tf` cria IGW, NAT Gateway e Service Gateway. A FAQ
oficial informa que criar/usar VCNs não tem tarifa, e que tráfego e outros
serviços são tarifados separadamente. Ela também declara o Service Gateway
gratuito. Não foi encontrada, nas fontes consultadas, uma tarifa específica
de NAT Gateway que justifique trocar a topologia existente.
[Oracle: Virtual Cloud Network FAQ](https://www.oracle.com/cloud/networking/virtual-cloud-network/faq/)

O NAT permite à VM privada iniciar conexões externas; removê-lo sem outro
caminho impediria downloads e o túnel Cloudflare usados no bootstrap.
[Oracle: NAT Gateway](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/NATgateway.htm)

Balanced usa 10 VPUs/GB; Higher Performance usa 20. A documentação Always
Free consultada não fixa explicitamente um teto de VPUs. Portanto, não há
base nestas fontes para afirmar que qualquer valor acima de 10 é cobrado,
nem para garantir gratuitidade de todo ajuste. Manter Balanced evita
alteração de desempenho desnecessária.
[Oracle: Block Volume Performance](https://docs.oracle.com/en-us/iaas/Content/Block/Concepts/blockvolumeperformance.htm)

## Limitações operacionais

A Oracle pode recuperar instâncias Always Free ociosas conforme critérios
de utilização de sete dias. A criação também depende da capacidade A1
disponível na região. Dimensionar dentro da franquia não garante capacidade
física nem disponibilidade contínua.
[Oracle: Always Free Resources](https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm)

Cloudflare R2 e os demais serviços externos têm suas próprias franquias;
não fazem parte da franquia OCI descrita aqui.
