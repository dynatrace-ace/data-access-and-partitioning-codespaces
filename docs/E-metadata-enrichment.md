## 🎯 Lab Goals

- Understand Primary Grail Fields (PGFs): what they are and why they’re ideal for tenant-wide controls (IAM, Partitioning, Segmentation, Cost).
- Assess current metadata coverage: run the Enrichment Overview notebook and a representative sample (dedup by host/PGI/service or iostream) to see presence of dt.security_context, dt.cost.costcenter, dt.cost.product, dt.host_group.id.
- Configure K8s-based enrichment (namespace level): map existing labels (e.g., kubernetes.io/metadata.name) to PGFs; apply in Dynatrace; understand effect on all signals.
- Validate by restarting workloads: roll out restarts (single service or all in easytrade) and confirm mutated pods carry new metadata.
- Propagate cost & access fields: add dt.cost.costcenter and dt.cost.product alongside dt.security_context; re-check notebook KPIs and per-signal examples.
- Handle exceptions (pod-level granularity): for loginservice, add pod template annotations in its manifest to set PGFs at workload scope; apply and verify.

Are you ready for some fun?

## 🧪 Exercises

Let's start by understanding what a Primary Grail Field is [here](https://dt-rnd.atlassian.net/wiki/spaces/d1coe/pages/1246757730/2.+Metadata+Enrichment) (_5 minutes_)

### Understanding Primary Grail Fields

1. Go to Segments, create a segment with the `dt.host_group.id`, and see how the Primary Grail Field gets propagated across every datapoint (metric, log, trace, event). You don't need

![](./img/host-group-pgf.png)

> Note: for entities we're waiting for Smartscape 2.0, customers can still rely/use Management Zones for that. It will work starting from January 2026

2. Without leaving the Segment, copy any attribute related to spans specifically. In the read we're using java.jar.file, but you can test it with any attribute, let's do for example span.name

![](./img/span-name.png)

3. Run the Segment once again but for span.name equals to the value you've selected

![](./img/span-name-results.png)

!!! success

  See how a Primary Grail Field is propagated across every signal, compared with other attributes. Those are good fits to be used for tenant-wise configurations such as Data Access, Partitioning, Segmentation & Cost Control

#### Why?

As explained in the D1 CoE page...

_In 3rd-Gen, each datapoint is treated independently, offering much greater flexibility in how data is: Grouped (via Buckets), Filtered (Segments), Secured (Access Control / IAM), Allocated (for cost tracking, DPS). Every signal, such as logs, spans, traces & metrics, should be enriched with the correspondant metadata. Entities are treated in a similar way to any other signal type._

So in order to fulfill the respective requirements from the table generated during the Slice & Dice exercise, we need to enrich every signal with:

- dt.security_context = easytrade
- dt.cost.costcenter = easytrade
- dt.cost.product = easytrade

Once we've enriched all signal with those values, we can start creating the following configuration for IAM, Cost Allocation, Buckets, Segmnetation!

#### How?

Enrichment works different depending the technology. For us we found that it is a K8s running on GCP. The D1 CoE is also providing a detailed [guide for each technology](https://dt-rnd.atlassian.net/wiki/spaces/d1coe/pages/1321173398/Enrichment+Technologies+Entities) (_1 minute_)

During this lab, we will focus on [K8s Enrichment](https://dt-rnd.atlassian.net/wiki/spaces/d1coe/pages/1229849653/Enrichment+Kubernetes) (_5 minutes_)

### Enriching our K8s Cluster

#### Coverage Notebook

4. Copy the [Enrichment Overview Notebook](https://guu84124.apps.dynatrace.com/ui/apps/dynatrace.notebooks/notebook/8e41313b-48fa-473b-a351-be9b3462c4f4) in your tenant, re-run the queries and understand the status for your customer

![](./img/enrichment-initial-status.png)

Notice how our existing customer is providing the HOST_GROUP, as being used to Classic Dynatrace but there is no dt.security_context, dt.cost.costcenter & dt.cost.product

As explained for the K8s scenario, there are different appraches

![](./img/K8s-approach.png)

#### Primary Grail Fields approach (Namespace)

5. Open a segment and use the namespace to retrieve all datapoints

![](./img/namespace-primary.png)

For customers that are willing to are willing to get value fast, they could use directly the namespace as their Primary Grail Field

You can even use the k8s.namespace.name in the IAM boundary configuration

![](./img/namespace-permission.png)

#### Cloud-native approach

But the customer is willing to propagate the required attributes across their environment (dt.security_context, dt.cost.costcenter, dt.cost.product)

Based on the 2nd approach, could we Rely on Namespace Annotations & Labels? Think that this is the way the customers usually organize their could-native environments

6. Go to the K8s app in Dynatrace, and check for customer's standards in defining labels & annotations

![](./img/k8s-annotations.png)

> Note: in a real customer scenario, you need to validate the values with them. It is important aling with company standards

7. Use `kubernetes.io/metadata.name` for the dt.security_context value

![](./img/label-sc.png)

!!! warning

    Make sure you select label, not annotation

##### Debugging

The Dynatrace Operator will start mutating pods within that namespace adding the dt.security_context

8. Run `kubectl get pods -n easytrade` within your cluster, check existing pods and copy the accountservice one

![](./img/getpods.png)

9. Describe the accountservice pod with `kubectl describe pods <accountservice-pod-name> -n easytrade`

![](./img/annotation-accountservice.png)

As you may see, no dt.security_context. The pod is running, we need a pod restart for the Operator to mutate the definition and the dt.security_context to reflects in the definition

10. Restart the accountservice deployment with

```bash
kubectl -n easytrade rollout restart deployment/accountservice
```

11. Check once again the new pod, repeat steps `8` & `9`. Now we should see dt.security_context within the pod definition

![](./img/accountservice-sc.png)

!!! warning
  After creating or modifying rules, allow up to 45 minutes for the changes to take effect. It usually doesn't take that long, repeat steps 8 & 9 until you see dt.security_context within your pod definition

12. Go back to your Enrichment Overview Notebook, and check the current status. Grab a span.id, paste it below and check for the workload name

![](./img/1st-sc-in-notebook.png)

13. Configure dt.cost.costcenter & dt.cost.product, and other useful attributes that the Easytrade Team was looking forward to use in Dynatrace

![](./img/rest-of-attributes.png)

14. Restart all deployments from easytrade namespace

```bash
for d in $(kubectl -n easytrade get deploy -o name); do
  kubectl -n easytrade rollout restart "$d"
done
```

15. Check your Enrichment Overview Notebook once again

![](./img/spans-well-done.png)

> Check logs. Why not all logs? Cluster-level spans, but there are cluster-level logs, that an infra team may be interested in?


#### Primary Grail Tags

As you may have seen, we've also added other attributes that could be extremely useful for the customer, such as the version.

16. The customer could create visualization of metrics, or exception maps comparing different version of their apps

![](./img/versions-in-segments.png)

!!! tip
    Consider also Primary Grail Tags, apart from the default enrichment of dt.security.context, dt.cost.costcenter and dt.cost.product. Think of the dimesions defined previously, or any relevant metadata that the customer could use in Dynatrace

#### Pod-level granularity

The loginservice is the only microservice from easytrade that is it not managed by the Easytrade team who we are helping with the PoC. There's a request to keep their Data Access separately.

The enrichment we've seen so far go as far as the namespace in terms of granularity, how can we achieve pod level granularity? How could we define a dt.security_context = loginservice?

17. Check your IDE, there's the loginservice resource file under .devcontainer/apps/easytrade/k8s-manifests/loginservice.yaml. Add the annotations to the pod definition

```yaml
annotations:
  # Custom tags for Dynatrace
  metadata.dynatrace.com/dt.cost.costcenter: "loginservice"
  metadata.dynatrace.com/dt.cost.product: "loginservice"
  metadata.dynatrace.com/dt.security_context: "loginservice"
```

![](./img/loginservicefile.png)

18. Redeploy based on the file

```yaml
kubectl -n easytrade apply -f .devcontainer/apps/easytrade/k8s-manifests/loginservice.yaml
```

19. You can check if the new pods of loginservice have the new dt.security_context values with

```bash
kubectl get pods -n easytrade
kubectl describe pods <loginservice-pod-name> -n easytrade
```

![](./img/loginservicenewsc.png)

20. Check your Enrichment dashboard one more time

![](./img/loginservicedash.png)

## 🌱 Closing Up

### Lab Recap & Next Steps

- You identified Primary Grail Fields and why they matter for tenant-wide controls.
- You measured metadata coverage on a representative sample (spans/logs) and tracked % with dt.security_context, dt.cost.costcenter, dt.cost.product, dt.host_group.id.
- You configured K8s enrichment (namespace labels → PGFs) and restarted workloads so pods were mutated with the new fields.
- You handled an exception at pod level (loginservice) by adding PGF annotations in its manifest and applying the change.
- You validated before/after in the Enrichment notebook and noted gaps (e.g., some cluster-level logs).

What this enables...
- dt.security_context is now your anchor dimension to define groups, policies, and access boundaries for least-privilege access.
- dt.cost.costcenter & dt.cost.product are ready for cost allocation and reporting.

### Resources

Dynatrace Official Documentation:
- [DT Doc | Global Field Reference](https://docs.dynatrace.com/docs/discover-dynatrace/references/semantic-dictionary/fields)
- [DT Doc | K8s Enrichment](https://docs.dynatrace.com/docs/ingest-from/setup-on-k8s/guides/metadata-automation/k8s-metadata-telemetry-enrichment)

D1 CoE:
- [D1 CoE | What a Primary Grail Fields is?](https://dt-rnd.atlassian.net/wiki/spaces/d1coe/pages/1246757730/2.+Metadata+Enrichment)
- [D1 CoE | Enriching by Technology](https://dt-rnd.atlassian.net/wiki/spaces/d1coe/pages/1321173398/Enrichment+Technologies+Entities)
- [D1 CoE | K8s Enrichment](https://dt-rnd.atlassian.net/wiki/spaces/d1coe/pages/1229849653/Enrichment+Kubernetes)

We've meet the Enrichment requirements for a K8s environment. How would this work for a Standard OA, or a Cloud environment. Check the following resources in the CoE page:
- [D1 CoE | Enrichment of Standard OneAgent deployment](https://dt-rnd.atlassian.net/wiki/spaces/d1coe/pages/1373569857/Enrichment+OneAgent)
- [D1 CoE | Enrichment for Cloud](https://dt-rnd.atlassian.net/wiki/spaces/d1coe/pages/1273104811/WIP+-+Enrichment+Cloud+Virtualization), WIP... contact the CoE in case further information is needed

<div class="grid cards" markdown>
- [Let's continue:octicons-arrow-right-24:](6-data-access.md)
</div>
