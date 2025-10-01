--8<-- "snippets/4-slice-and-dice.js"

## Slice & Dice

### Objectives

- Work with an existing customer scenario presented previously.
- Learn how to extract and map:
  - 📋 Requirements
  - 📐 Dimensions
  - 🖥️ Technologies

### Step 1: Understand the 📋 Requirements (Interactive Discovery)

The customer requirements are:

- Teams should only access their own apps, those apps being easytrade and hipstershop. This includes ALL DATA.
- Both easytrade and hipstershop logs need a separate bucket. Think about routing rules for logs and their respective buckets considering that everything is deployed in a kubernetes environment.
- Customers needs to be able to easily navigate through Dynatrace interface and see their respective apps as well as app signals.
- Costs need to be split by each application to understand how much each team is spending on Observability overall.

### WHAT NOW?

**What are some questions you would ask yourself before doing the hands on work?**

<details>
  <summary>Here's how you get there...</summary>

#### 🔐 Access Control

Goal: Understand who should access what data. Think about all questions that you need to ask your customer to uncover this. For example:

- Who should be able to access which data sets?
- Are there any restrictions based on data sensitivity or compliance?
- Do different teams need isolated views of their own applications?
- Do you need to go more granular than just the application view?

#### 🧱 Partitioning (Bucket Strategy)

Goal: Identify how different signals should be stored and if they should be separated.

- Can you think of reasons why logs might need to be stored in separate buckets?
- What about log retention: should all logs be kept for the same duration? Usually that's not the case.
- Based on log volume, would query performance be affected?
- Could separating logs into their respective application buckets help with cost control? Do you think this is best practice?

#### 🎯 Segmentation

Goal: Determine how data should be filtered and grouped for visibility.

- What would be the best way to split your customer's data for visibility?
- Would you like to filter by app, environment, region, or business unit? What do you think is the best approach?
- How would this affect your data access?

> Think about the move from Management Zones to IAM + Segments. What can people have access to vs what can they only filter on?

#### 💰 Cost Allocation

Goal: Understand how observability costs should be tracked and distributed.

- How would your customer like to allocate costs?
- Should costs be split by application, team, or department?
- Do you need a chargeback or showback model for budgeting?

</details>

### Discover 📐 Dimensions

> 💡 Dimensions = metadata used to tag and organize observability data.

Instructions:

1. Copy the notebook: https://guu84124.apps.dynatrace.com/ui/document/v0/#share=06f00290-72b6-4a03-930d-5a7bf17de35e
2. Explore metadata sources:
   - Host Groups
   - MZ rules
   - Tag Rules
     Look for tags that reveal dimensions like platform, app, stage, team, etc.

Write down the dimensions you discover:

- ***
- ***
- ***

### 🖥️ Technologies

Find out underlying technologies -> in this case, we have K8s.

> 💡 Understand the infrastructure to enrich observability data.

🔍 Questions to Ask

- What cloud providers are used? (e.g., AWS, GCP, on-prem)
- Is Kubernetes or serverless in use?
- What tagging strategies exist across environments?
- What Dynatrace metadata can be leveraged? (e.g., HOST_GROUPS)

Different technologies require different set-ups and depending on whether something is on-prem or serverless, it will rqeuired a different kind of set up for each of these.

### Map requirements with dimensions

| Requirement     | Dimension                                                                             |
| --------------- | ------------------------------------------------------------------------------------- |
| Data Access     | dt.security_context = easytrade (same for hipstershop)                                |
| Partitioning    | k8s.namespace.name                                                                    |
| Segmentation    | segment for easytrade and hipstershop                                                 |
| Cost Allocation | dt.cost.costcenter = easytrade and dt.cost.product = easytrade (same for hipstershop) |

### Resources

- [Slice and Dice](https://dt-rnd.atlassian.net/wiki/spaces/d1coe/pages/1247150978/1.+Slice+Dice)
- [Slice and Dice - Existing Customer Scenario](https://dt-rnd.atlassian.net/wiki/spaces/d1coe/pages/1251903308/Slice+Dice+Existing+Customer)
- [Slice and Dice - Example Scenario](https://dt-rnd.atlassian.net/wiki/spaces/d1coe/pages/1298433988/Slice+Dice+Example+Scenario)

<div class="grid cards" markdown>
- [Let's continue:octicons-arrow-right-24:](5-metadata-enrichment.md)
</div>
