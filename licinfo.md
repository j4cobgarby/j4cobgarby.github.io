---
layout: default
title: Licentiate Info
---


# Optimising Asynchronous Deep Learning on Highly Parallel Processors
## Overview of My Licentiate Thesis

### Contents

 - [Introduction](#introduction)
 - [Paper A](#paper-a) -- Interval-Asynchrony
 - [Paper B](#paper-b) -- ForestTune

<center>
<h1 id="introduction">Introduction</h1>
</center>

The impressive performance of modern artificial intelligence systems arises as a result of deep machine learning, which, after processing a set of training data, produces accurate and reliable AI models. These models have found endless applications, including financial forecasting, natural language processing, autonomous robotics, computer games, and, increasingly, language modelling for virtual assistants and coding.

As we imagine more and more complex use cases, we tend to as a result require tremendous quantities of data -- and similarly huge amounts of processing power -- to produce the models we want. If we wish to continue this progression, we either need models that are more efficient to train; significantly more powerful or scalable compute hardware; or more efficient training algorithms. In this thesis, we focus on the latter.

For some time now, the performance of individual compute units has begun to plateau. In response, people with a need for high performance computing must investigate ways of orchestrating a number of individual processors together in a scalable way to increase the total processing power. This is what parallel processing is.

Executing machine learning <i>efficiently</i> in parallel is not trivial, since as we introduce more and more processors to a system, we introduce significant overhead in the strict, consistent case. This is because all the processors need to synchronise with each other to produce an absolute correct result.

We consider methods of relaxing this synchronisation. Executing training algorithms _asynchronously_ can greatly improve the speed at which data is processed, but if done carelessly can significantly harm the convergence rate and eventual model quality. We therefore explore different methods of controlling -- and taming -- this asynchrony.

---

# Paper A
## Interval-Asynchrony: Delimited Intervals of Localised Asynchrony for Fast Parallel SGD
#### Presented at [Euro-Par 2025](https://link.springer.com/chapter/10.1007/978-3-031-99857-7_17)

The first paper in my thesis explores a novel approach to executing stochastic gradient descent (SGD) in a mostly asynchronous way (good for throughput), while efficiently bounding staleness to achieve fast convergence.

## Motivation
Parallelism is a popular approach to <b>scale SGD</b>, in which a large number of processing devices (think CPUs, GPUs, etc.) are orchestrated together to improve training throughput.

Traditionally, parallel SGD is formulated as a synchronous algorithm, but unfortunately that struggles due to significant <b>synchronisation overhead</b>.
For this reason, asynchronous implementations are increasingly common.

These provide an improvement in throughput at the expense of introducing <b>stale gradients</b> which reduce the effectiveness of individual SGD steps.

Previous approaches to mitigate the downsides of asynchronous processing include adaptively
adjusting the number of worker threads or the learning rate, but at their
core these are still fully asynchronous and hence still suffer from lower
accuracy due to frequent staleness.

## Interval-Asynchrony

When executing SGD asynchronously (i.e. according to Hogwild! semantics), workers are free to update a shared set of model parameters at any time. This means that between the moment that a given worker pulls a copy of the parameters, and the moment that they finish calculating a gradient to update the model, the model may have been updated several times by other workers. The number of overlapping updates is called _staleness_.

In this work we analyse the origin of such staleness, and as a result propose _Interval-Asynchrony_, a **semi-asynchronous** method which
retains high throughput while reducing gradient staleness, both on average as well as with a hard upper bound.

![](/assets/img/interval-async-overview.png)

To do so, we introduce periodic <b>asynchronous intervals</b>, depicted above. Within one interval, SGD is executed asynchronously, gradient computations may not cross interval boundaries. An interval is defined by a number of accepted SGD steps. The size of these intervals determines the degree of asynchrony, providing us with an adjustable scale.

## Interval Size

It turns out that the optimal size of asynchronous intervals &mdash; the parameter that Interval-Asynchrony introduces &mdash; depends on the stage of execution. It tends to require smaller intervals later on, and can put up with larger intervals earlier for better throughput.

Unsurprisingly, it's not trivial to determine the interval size schedule beforehand. In the paper we propose two methods for adjusting it, and evaluate each:

 - Linear decay. Reduce interval size by a constant for every <i>n</i> accepted steps.
 - Probing. This method, inspired by <i>ElAsyncSGD</i>, periodically trials execution at nearby interval sizes and checks if any seem to work better at the current stage.

When dialled in, linear decay has the potential to outperform probing. However, we propose that probing is easier to apply to new, unknown workloads. This behaviour can be seen in figures 4 and 5 in the paper.
## Artefacts &amp; Downloads

<iframe height="300px" style="max-width: 65%; float: left; margin: 5px 25px;" src="https://www.youtube.com/embed/RnzR7FxzWx8?si=j6N3mjfjr-Imf2ru&amp;start=19" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

Here, you can find a recording from my presentation of this paper at Euro-Par 2025 in Dresden. You can also find a slightly more in-depth blog post about the paper and the conference <a href="http://127.0.0.1:4000/blog/2025/09/03/Euro-Par-2025.html">here!</a>

- Presentation slides (<a href="/assets/Europar2025.pdf">PDF</a>) (<a href="/assets/Europar2025.odp">ODP</a>)
- Conference paper (<a href="/assets/pdf/int_async.pdf">PDF</a>)
- <a href="https://zenodo.org/records/15576941">C++ implementation</a>

## Evaluation
        
Our focus for this work is on CPU training for highly parallel systems. We therefore picked baseline algorithms and training workloads that are sensible for this setting.

We compared against the following algorithms that control the execution:
 - Fully synchronous (traditional);
 - Fully asynchronous; and
 - ElAsyncSGD &mdash; fully asynchronous with dynamic number of threads.
And we considered both <span>CIFAR-10</span> and <span>CIFAR-100</span> datasets, for which we train a model to recognise what a given image is of.

I recommend reading section 5 of <a href="/assets/pdf/int_async.pdf">the paper</a> for an in-depth evaluation, but the takeaway numbers are:
<ul>
<li>Reduction in training time to same accuracy of up to 32%.</li>
<li>Solid scalability up to 128 threads.</li>
<li>Better final accuracy compared to asynchronous baselines, and competitive with fully synchronous (exact) method.</li>
</ul>

## Visualisation

To better explain how Interval-Asynchrony works, compared to synchronous and asynchronous, you can play around with the interactive visualisation below.

Experiment with each execution mode, and consider:
 - How do different interval sizes affect throughput and staleness?
 - What's the difference in staleness distribution between our method and asynchronous?

Simply press "Begin" to start.

<iframe id="simframe" src="/sgdvis.html" style="width:100%;height:620px;border:0" title="Interval-Asynchrony Visualisation" loading="lazy"></iframe>


<script>
(function () {
  const frame = document.getElementById('simframe');
  addEventListener('message', e => {
    if (e.source !== frame.contentWindow) return;
    if (e.data && e.data.type === 'ia-sim-height')
      frame.style.height = e.data.height + 'px';
  });
})();
</script>

<hr>

# Paper B
## ForestTune: Resource-Aware Hyperparameter Schedule Discovery as a Tree Search
[Paper Download](/assets/pdf/foresttune_do_not_share.pdf)

The second paper explores hyperparameter tuning considering that hyperparameters may be adjusted throughout an execution, and taking into account system resources. We structure the hyperparameter search as generating a forest structure.

## Motivation
Hyperparameter tuning is a critical component of modern machine learning pipelines, as the performance and efficiency of many data processing workloads depend heavily on the choice of hyperparameters. We can see a perfect example of this by looking at <a href="#paper-a">Paper A</a>, in which we significantly speed up SGD but only by introducing a tuneable hyperparameter.

While most traditional tuning methods in the literature assume static configurations, many hyperparameters (including the aforementioned <i>interval size</i> for Interval-Asynchrony) benefit from being adapted during execution.

There are existing works which implicitly exploit scheduling effects, including <i>PBT</i> and <i>PB2</i>, however they just consider a flat population of independent trials, and only model algorithmic hyperparameters as tuneable. As a result, they lack principled mechanisms for branching executions, consideration of system-level parameters for scheduling, and re-evaluation of configurations under stochasticity.

## ForestTune

Overall, our idea is this: organise tuning trials as nodes in a forest structure. This allows checkpoints to branch and consider several hyperparameter schedules more efficiently.

Our proposed method, <i>ForestTune</i>, represents a tuning checkpoint (i.e. a pair of a model checkpoint and a set of hyperparameters which that checkpoint was reached with) as a node in a forest, pictured below. This structure allows executions to branch and explore alternative schedules without restarting training from scratch. Furthermore, system resource parameters are treated as first‑class hyperparameters, enabling efficient trial scheduling and reuse of intermediate execution state.

![Forest](/assets/img/forest_agg.png)

The diagram above represents an example of how a forest might develop over the course of a <i>ForestTune</i> execution. The numbers refer to the iteration during which a node was created.

## Forest Growth

All nodes that get created are subsequently evaluated to guage their performance. Our growth algorithm therefore needs to be designed precisely: it must be discerning enough that it only proposes new nodes that are actually worth taking the time to evaluate, while simultaneously being broad enough to discover unexpected optimal schedules.

We divide an entire <i>ForestTune</i> execution into a number of <i>seasons</i>. In each season, a forward pass is run over the whole forest from root to leaf, and at each depth, new nodes are branched from existing ones.

![Branching](/assets/img/branching.png)

The diagram above describes the different mechanisms through which new nodes can be produced. Each individual node holds its own Bayesian optimisation model (which it initially inherits from its parent) that allows it to smartly choose child configurations. Bayesian optimisation is therefore the preferred generation method, but in such cases that the B.O. models are not yet populated with enough samples, we use random sampling for root nodes and mutation (small offsets from parent configurations) for non-root nodes' configurations.

## Evaluation (not up to date)

We assess <i>ForestTune</i> against two state-of-the-art hyperparameter tuning baselines: PB2, which, like <i>ForestTune</i>, also adjusts hyperparameters <i>during</i> training; and BOHB, a widely-used method that holds each configuration fixed per trial. Our evaluation aims to address the following questions:

 - Does <i>ForestTune</i>'s support for mutable hyperparameters yield better-tuned models, and reach a given quality faster, than the baselines?
 - Does <i>ForestTune</i> efficiently convert wall-clock time and evaluation budget into tuning progress?
 - Is <i>ForestTune</i> practical in terms of the memory and storage overhead?
 
![Evaluation](/assets/img/cifar_vs_time.png){: .right}
 
In short, the answer to all the above questions is "yes". I'd recommend taking a look at <a href="/assets/pdf/foresttune_do_not_share.pdf">the paper</a> for a detailed evaluation, but for a taste, take a look at the plot to the right.

Higher is better. <i>ForestTune</i> is able to much more efficiently reach better model accuracy, due to its efficient resource-aware configuration evaluation scheduling and the fact that it can evaluate several similar schedules much more quickly than PB2 due to its ability to resume from checkpoints.
