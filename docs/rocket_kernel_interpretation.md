# ROCKET Kernel Summary — How to Interpret Results

## Panel A — Kernel length distribution

Lengths are sampled **uniformly** from {7, 9, 11}, so you expect roughly equal thirds. If one bar is much taller it's just random sampling noise — it has **no effect on quality** since ROCKET compensates through the sheer number of kernels.

What matters: length controls **how local** the pattern each kernel detects is. Length 7 = very local shape, length 11 = slightly wider shape. The difference is minor compared to dilation.

---

## Panel B — Dilation distribution

This is the **most important panel**. Dilation is sampled exponentially, so:
- Most kernels have **small dilation** (1–5) → detect fine-grained, local patterns
- A few kernels have **large dilation** (50, 100+) → detect long-range, slow trends

If your time series has important **periodic structure** (e.g. heartbeat, seasonal signal), the kernels whose dilation matches the period will produce high activations. The exponential spread ensures ROCKET covers all scales without you having to tune anything.

**Red flag**: if all dilations are tiny, long-range patterns in your data won't be captured.

---

## Panel C — Bias distribution

Biases are uniform random in roughly [-1, 1]. The bias shifts the entire feature map up or down, which changes the **PPV threshold**:
- Large positive bias → feature map shifted up → more values > 0 → PPV inflated toward 1.0
- Large negative bias → feature map shifted down → fewer values > 0 → PPV near 0

On its own a single kernel's bias is not interpretable. What matters is the **ensemble effect**: across many kernels, the varied biases ensure PPV spans the full [0, 1] range, giving the ridge classifier rich signal to work with.

---

## Panel D — PPV distribution

PPV = proportion of positive values in the feature map. This is arguably **ROCKET's most powerful feature**.

Interpret it as: *"what fraction of the time does this kernel's pattern appear in the series?"*

A **healthy distribution** is spread across [0, 1] — some kernels fire rarely (PPV ≈ 0), some always (PPV ≈ 1), most somewhere in between. This spread is what gives the linear classifier enough variation to find a separating hyperplane.

**Red flags**:
- PPV bunched near 0 → most kernels never activate on this sample → the series might be unusual or the kernels are poorly scaled
- PPV bunched near 1 → most kernels always activate → no discriminative signal

---

## Panel E — Max distribution

Max = the single highest activation value across the entire feature map. Think of it as: *"how strongly does this kernel's pattern appear at its best match location?"*

- A kernel with **high max** found a region in the series that strongly matches its weight pattern
- A kernel with **max near 0** is essentially inactive on this sample — it found no matching structure

Unlike PPV, max is sensitive to **amplitude**. A noisy or high-variance series will produce higher max values across the board. This is why the standard scaler sits between the Rocket transformer and the ridge classifier in the pipeline — it normalizes these amplitudes across the training set.

**Red flag**: if the max distribution is extremely right-skewed (a few kernels with enormous max), those kernels may dominate the ridge classifier's decision.

---

## Panel F — Max vs PPV scatter (colored by dilation)

This is the **most diagnostic panel** for understanding what's happening on a specific sample.

Read it in four quadrants:

```
          PPV
high │  fires often,   │  fires often,
     │  weakly         │  strongly
     │  (noisy match)  │  (clear pattern)
─────┼─────────────────┼──────────────── max
     │  rarely fires,  │  rarely fires,
low  │  weakly         │  strongly
     │  (irrelevant)   │  (sharp spike)
     └────── low ──────┴──── high ───►
```

- **Top-right** (high PPV, high max): kernel found a pattern that appears frequently AND strongly → very informative for classification
- **Top-left** (high PPV, low max): kernel fires often but weakly → may be capturing baseline drift rather than a real pattern
- **Bottom-right** (low PPV, high max): kernel fires rarely but with a strong spike → may be detecting a rare but diagnostic event
- **Bottom-left**: kernel is essentially uninformative for this sample

The **color (dilation)** tells you the scale: if most top-right points are dark (low dilation), the discriminative patterns are local. If they're bright (high dilation), the class is distinguished by long-range structure.

---

## Panel G — Mean |weight| per kernel

This shows the **magnitude** of each kernel's weights, sorted from strongest to weakest.

A kernel with high mean |weight| is more **decisive**: it responds strongly to matches and strongly suppresses mismatches. A kernel with low mean |weight| produces a nearly flat feature map — it barely reacts to the series at all.

In a well-fitted model you expect a smooth decay — a few strong kernels followed by a long tail of weaker ones. A flat bar chart (all kernels similar) means no kernel is particularly tuned to the data, which is expected and fine since weights are random — the ridge classifier compensates by weighting the resulting features differently.

---

## Putting it all together

The key insight is that **no single kernel matters**. ROCKET's power comes from the ensemble:

1. With enough kernels, the random weight/dilation/bias combinations will accidentally produce features that separate the classes
2. The **ridge classifier** then learns which of the 2K features (max and PPV per kernel) are actually useful and assigns them high coefficients
3. Features from uninformative kernels get coefficients near zero and are ignored

So the right way to interpret the summary is not "is kernel 47 good?" but rather:
- Is the **dilation range** wide enough to cover my signal's timescales?
- Is the **PPV spread** wide enough to give the classifier varied signal?
- Are there **top-right clusters** in panel F, meaning at least some kernels strongly match discriminative patterns?

If all three are yes, ROCKET has the raw material to classify well — and the ridge classifier's job is just to find the right linear combination.
