In order to execute a solid 3rd-Gen Data Access & Partitioning Design, we need have a clear understanding of our customer's:

- 📋 Requirements
- 📐 Dimensions
- 🖥️ Technologies

## Existing or New Customer?

For a new customer, it is important to gather those requirements directly from them. For that, D1 CoE is providing guidance on some of the key questions you may want to raise during that conversation [here](https://dt-rnd.atlassian.net/wiki/spaces/d1coe/pages/1247150978/1.+Slice+Dice).

For an existing customer, they were already doing it in a certain way. Customers used to rely on Management Zones to configure their Data Access (and Segmentation). For an existing customer, it is useful to conduct a pre-investigation (if possible) to gather information beforehand.

## Existing customer Pre-investigation

### 1. Data Access (_reading exercise..._)

Dynatrace Classic Data Access was role based (RBAC), and the permissions used to look like this

![](./img/RBAC.png)

For our exercise, we will provide you screenshots on how Access Control looks like for Easytrade, as we can't create RBAC as for today in Dynatrace, but you should check the following too during a customer engagement

![](./img/group-rbac.png){ width="50%" }

![](./img/policy-rbac-mz.png)

The customer was creating groups for individual MZ, for users to be linked with those groups, and being able to see everything that lives inside of it

!!! tip
    This approach was convenient/easy, but not ideal. Imagine a shared infrastrucuture. How would you have been able to give access to each team to their own logs, if the permission was connected to the entity itself?

    With Dynatrace 3rd-Generation Platform, every single datapoint (i.e. entity, logs, spans) are treated independently, meaning that you could give each team access to their own stuff

Back to the exercise... what we noticed during this pre-investigation, is that for our customer scenario...

!!! success
    Congratulations, we found the Data Access requirement for our customer in Classic
    - Teams should only access their own apps  
    - The customer uses Management Zones in Dynatrace Classic

    It rest to validate with the customer

### Dimensions & Technologies (exercise)

#### What do we mean with Dimensions?

For our customer scenario, _app_ is a dimension, and Easytrade the value. 

Dimensions are key–value pairs that describe context for a metric, log, or trace. They turn raw data into actionable information by allowing you to slice, filter, and aggregate.

Customers use to store these dimensions within HOST_GROUP coming directly from the source, define them as tags and/or Management Zones

1. Explore the dimensions within your customer environment. You can use [this](https://guu84124.apps.dynatrace.com/ui/document/v0/#share=06f00290-72b6-4a03-930d-5a7bf17de35e) notebook

<div id="reader-notes"></div>

## Exercise

Explain dimensions 
💡 Dimensions = metadata used to tag and organize observability data.
How customer segregates data


1. find dimensions (host group, MZ, tags), use notebook 



2. find technologies. Explain that it is important for the enrichment part

Briefly explain importance of knowing the technology, if it is a regular VM, compared to K8s, and Cloud, all different Enrichment mechanism, point to Confluence

## Requirements

Data Access
- Teams should only access their own apps
- The customer uses Management Zones in Dynatrace Classic

Data Segmentation
- Customers needs to be able to easily navigate through Dynatrace interface and see their respective apps as well as app signals.
- Using also Management Zones, as other dimensions. We may have to find out!

Data Partitioning
- They didn't have such thing in Classic, we'll implement a bucket strategy to meet their requirements and improve performance & costs

Cost Allocation
- they want to track the spending for each app


3. Map with metadata

??? example "Solution"

    ### Solution

    | Requirement     | Dimension                                                                             |
    | --------------- | ------------------------------------------------------------------------------------- |
    | Data Access     | `dt.security_context = easytrade` (same for hipstershop)                              |
    | Partitioning    | `k8s.namespace.name`                                                                  |
    | Segmentation    | Segment for Easytrade and Hipstershop                                                 |
    | Cost Allocation | `dt.cost.costcenter = easytrade` and `dt.cost.product = easytrade` (same for hipstershop) |

    
  
4. What you just did is just a pre-investigation, validate the results with the customer. We simulate that customer is ok with that, we continue the exercise to the enrichment!

### Resources

- [Slice and Dice](https://dt-rnd.atlassian.net/wiki/spaces/d1coe/pages/1247150978/1.+Slice+Dice)
- [Slice and Dice - Existing Customer Scenario](https://dt-rnd.atlassian.net/wiki/spaces/d1coe/pages/1251903308/Slice+Dice+Existing+Customer)
- [Slice and Dice - Example Scenario](https://dt-rnd.atlassian.net/wiki/spaces/d1coe/pages/1298433988/Slice+Dice+Example+Scenario)

<div class="grid cards" markdown>
- [Let's continue:octicons-arrow-right-24:](5-metadata-enrichment.md)
</div>
