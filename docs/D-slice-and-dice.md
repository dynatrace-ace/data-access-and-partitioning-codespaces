## Lab Goals

By the end of this lab, you will:

- Understand the customer’s requirements, dimensions, and technologies for 3rd-Gen Data Access & Partitioning.
- Perform a pre-investigation for an existing customer scenario.
- Identify key dimensions and technologies to enable: Granular data access using dt.security_context, Cost allocation with dt.cost.costcenter and dt.cost.product
- Validate findings against customer requirements to guide the next stage: metadata enrichment at source.

## Exercises

To execute a solid 3rd-Gen Data Access & Partitioning design, we need a clear understanding of the customer’s:

- 📋 Requirements
- 📐 Dimensions
- 🖥️ Technologies

### Existing or New Customer?

**New Customer**: Gather requirements directly from them. D1 CoE provides guidance on key questions to ask during these conversations [here](https://dt-rnd.atlassian.net/wiki/spaces/d1coe/pages/1247150978/1.+Slice+Dice).

**Existing Customer**: They already have an approach in place. Historically, customers relied on Management Zones for Data Access and Segmentation. For these cases, conduct a pre-investigation (if possible) to collect relevant information beforehand.

For this lab, as presented earlier, we’re working with an existing customer, so we’ll proceed with a pre-investigation.

### Existing Customer Pre-investigation

#### Data Access (_reading exercise..._)

Dynatrace Classic Data Access was role-based (RBAC), and permissions looked like this:

![](./img/RBAC.png)

For this exercise, we’ll provide screenshots of Easytrade’s Access Control since RBAC cannot be created in Dynatrace sprint today. During a real customer engagement, you should also review:

![](./img/group-rbac.png){ width="50%" }

![](./img/policy-rbac-mz.png)

In Classic, customers often created groups for individual Management Zones (MZ). Users were linked to these groups, granting visibility into everything within that zone.

!!! tip
    This approach was simple but not ideal. In a shared infrastructure, how would you give each team access to their own logs if permissions were tied to the entity itself?

    With Dynatrace 3rd-Generation Platform, every datapoint (entities, logs, spans) is treated independently, allowing granular access for each team.

Back to the exercise: during pre-investigation, we found the following for our customer scenario:

!!! success
    - Teams should only access their own apps
    - Customer uses Management Zones in Dynatrace Classic

    Following the investigation with a customer **validation**.

#### Dimensions (exercise)

##### What do we mean by Dimensions?

In our customer scenario, app is a dimension, and Easytrade is its value.

Dimensions are key–value pairs that provide context for metrics, logs, or traces. They transform raw data into actionable insights by enabling slicing, filtering, and aggregation.

Historically, customers stored dimensions in HOST_GROUP (from the source) or defined them as tags and/or Management Zones.

1. Explore the **dimensions** within your customer environment. You can use [this](https://guu84124.apps.dynatrace.com/ui/document/v0/#share=06f00290-72b6-4a03-930d-5a7bf17de35e) Notebook

<!-- Dimensions Notebook -->
<div class="notes-widget"
     data-required="app, environment, component, platform"
     data-hint="Write down the key dimensions you discover."></div>

!!! tip
    Dimensions give us a clear way to slice and dice a customer’s environment:
    
    - **Metadata Enrichment at Source**: Identify which attributes should be added as metadata during ingestion. Ensure these enrichments align with tagging standards for cloud-native environments.
    - **Security Context**: Determine which dimensions can be leveraged as dt.security_context
    - **Bucket Strategy**: Avoid excessive bucket creation (e.g., 18k apps across 30 BUs should not result in 36k buckets). Use a multi-dimensional approach, group lighter apps by Business Unit (BU). Assign dedicated buckets to high-volume apps (those with higher TB/day traffic).

#### Technologies (exercise)

2. Explore the **technologies** within your customer environment. You can use [this](https://guu84124.apps.dynatrace.com/ui/document/v0/#share=06f00290-72b6-4a03-930d-5a7bf17de35e) notebook

<!-- Technologies notebook -->
<div class="notes-widget"
     data-required="gcp, k8s"
     data-aliases='{
       "gcp": ["google cloud", "google_cloud_platform", "google cloud platform", "gcloud"],
       "k8s": ["kubernetes", "kube"]
     }'
     data-hint="Write down the customer technologies you discover."></div>

!!! tip

    Previously, customers relied heavily on auto-tags, which often led to performance issues due to excessive processing and complexity. With Dynatrace 3rd-Gen, the recommended approach is to enrich metadata at the source, ensuring better scalability and efficiency.

    The enrichment strategy should adapt to the underlying technology. Different platforms (e.g., Kubernetes, AWS, Azure, OpenShift) offer distinct tagging and annotation mechanisms, so best practices must be tailored accordingly.

## Summary

### Requirements

With our findings on RBAC, Dimensions, and Technologies, and leveraging the [Slice & Dice](https://dt-rnd.atlassian.net/wiki/spaces/d1coe/pages/1247150978/1.+Slice+Dice), we are prepared to:

- Validate customer requirements
- Map critical fields for the next stage, including: `dt.security_context`, `dt.cost.costcenter`, `dt.cost.product`

Resulting in the following:

| Area            | Requirement                                                                                       | Dimension                                                                              |
|-----------------|---------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------|
| Data Access     | <ul><li>Teams should only access their own apps</li><li>The customer uses Management Zones in Dynatrace Classic</li></ul> | `dt.security_context = <app>` (easytrade)                               |
| Partitioning    | <ul><li>They didn't have such thing in Classic, we'll implement a bucket strategy to meet their requirements and improve performance & costs</li></ul>                                                                                                 | App, we could use `dt.security_context`                                                                |
| Segmentation    | <ul><li>Customers needs to be able to easily navigate through Dynatrace interface and see their respective apps as well as app signals.</li><li>Using also Management Zones, as other dimensions. We may have to find out!</li></ul>                                                                                                | All Dimensions as a Segment, set missing dimensions as Primary Grail Tags                                                  |
| Cost Allocation | <ul><li>They want to track the spending for each app</li></ul>                                                                                                 | `dt.cost.costcenter = <app>` and `dt.cost.product = <app>` (easytrade) |

### Technologies

K8s running on GCP, important to understand the most convenient enrichment mechanims for the customer

!!! note

    This table will be quite useful for the next steps. Keep it in a separate tab to help yourself set things up accordingly

### Resources

To save in your bookmarks!

- [3rd-Gen setup helper - Notebook](https://dt-rnd.atlassian.net/wiki/spaces/d1coe/pages/1247150978/1.+Slice+Dice) to execute pre-investigation
- [How to gather requirements from customer - CoE page](https://dt-rnd.atlassian.net/wiki/spaces/d1coe/pages/1247150978/1.+Slice+Dice)
- [Why Not Management Zones - CoE page](https://dt-rnd.atlassian.net/wiki/spaces/d1coe/pages/1291617117/Why+not+Management+Zones), drive better conversations about enrichment at source, motivate your customer to scalable and cluster-friendly approaches.

!!! collab
    We’d love to hear from you! If you have best practices, ideas, or suggestions to improve existing content—whether in Notebooks or CoE pages, please share them with us. Your input helps us make this material more valuable and actionable for everyone.


<div class="grid cards" markdown>
- [Let's continue, hopefully a bit more hands-on and less bla bla:octicons-arrow-right-24:](E-metadata-enrichment.md)
</div>



