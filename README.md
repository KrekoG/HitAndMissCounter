# Hit and miss counter
A WoW 1.12 addon that allows you to record your melee auto-attack hits and misses.

Use the command `/ham` to find out more.

## Installation instructions
1. Press the green "code" button -> Download ZIP
2. Extract the `HitAndMissCounter-main.zip` file and rename the extracted folder to `HitAndMissCounter`, then move it to your client's `\Interface\AddOns\` folder.
3. Start/Restart your game


# The expirement this was originally used for

## The issue

What I keep running into in the game is the clustering of chances. Did you just miss once? Well prepare to miss again a couple times shortly and then not for quite a while. Did you just make a yellow item and not receive a point? Carry on and you won't receive a point. Or take a break from crafting, restart in a minute and you are back to getting points. Did you just loot a green item? Well this is your lucky day, here's the same exact green item, with the same exact "of the ..." bonuses. All of this could be just confirmation bias, but given how I don't remember running into this in other servers I decided to run an experiment to see if it is the engine.

I wrote an addon that records when your auto-attack hits, or misses, and logs the event. The result is a file with hits and misses in order of them happening, so if this is the case, surely we will be able to notice a pattern here. (Or confirm the bias)

To avoid cherry-picking data, and to save some of my sanity I decided to keep punching the dummy in the Gurubashi arena, done this for literal hours. I'm going to try and document it in such a way that if you feel like following along and doing the same, you should have an easy time reproducing it with just a bit of technical knowledge. So feel free to download the addon and start punching things. Bear in mind it is important to keep the circumstances the same throughout the gathering of the data if we want to get meaningful conclusions.

## Getting the data

Once you are done with your testing run, close the game (or at least log out from your account) and grab the following file:
`..\<WoW Plus folder>\WTF\Account\<your account name>\SavedVariables\HitAndMissCounter.lua`.
Then we will want to remove all the unuseful bits, starting at the very beginning and end of the files.

After that, regex is going to make our life easier, if you don't know what that is, dont worry about it, just use a text editor that supports pattern matching, like atom.io, and when using the replacing functionality copy in the following (oh, and don't forget to turn on the pattern matching or it won't find anything):


Here's the regex to clean up the data:
- match: `\t*\[\d*\] = "(hit|miss)",`
- replace with: `$1`

Delete the lines that inform us about the addon starting to record (might as well do it manually if you had just one run, but one way or another it needs to be gone):
- match: `\t*\[\d*\] = "(startup)",\n` (If the `\n` doesn't result in matches, put an extra line at the end of the expression)
- replace with: ` ` (basically nothing so the line is removed)

Example input:
```
HAM = {
	["hit"] = 1,
	["record"] = false,
	["data"] = {
		[1] = "startup",
		[2] = "hit",
		[3] = "miss",
	},
	["miss"] = 1,
}
```

Example output:
```
hit
miss
```

## Checking the results

### The two example datasets:

The target used was the lvl 60 dummy in the Gurubashi arena, using only auto-attacks. The character was a troll shaman with a 1.5 speed dagger, and nothing in the off hand. Also had the `Nature's Guidance` talent, providing 3% to hit.

- https://vanilla-wow-archive.fandom.com/wiki/Hit

According to the formula of the wow wiki's hit page, `5% + (Defense Skill - Weapon Skill)*.1%` should produce my miss chance:
The dummy is lvl 60, so it should be `0.05 + (300 - 305) * 0.001`, giving us a 4.5% chance to miss, plus the 3% from the talent would result in 1.5% miss chance, which I'm sure is incorrect, therefore I must be doing something wrong. If you know better, please advise. So instead of using that calculation as my miss chance, I'm going to use 8%, as both of my datasets are close to it and it is slightly bigger than what I would expect it to be, making the calculations more forgiving to clustering. After all I'm trying to prove that they exist, bias should be minimised.


#### Dataset 1:
```
Total: 3045
Hits: 2810
Miss: 235
Miss chance: 7.72%
```

#### Dataset 2:
```
Total: 4008
Hits: 3685
Miss: 323
Miss chance: 8.06%
```

The following article explains how we can reach a formula that helps us predict how many clusters we should be seeing in the dataset.

https://mindyourdecisions.com/blog/2015/02/16/monday-puzzle-two-heads-in-a-row/

And the formula from the article is `X = (p^-n – 1)/(1 – p)`, where:
- X is the average number of auto-attacks to see a certain sized cluster
- p is our chance to miss, in this case p = `0.08`
- n is the number of misses in a row, basically describing our pure cluster, where there were no hits between misses.

Let's run this calculation for a couple pure cluster sizes:


1. `X = (0.08^-1 – 1)/(1 – 0.08) = 12.5`

2. `X = (0.08^-2 – 1)/(1 – 0.08) = 168.75`

3. `X = (0.08^-3 – 1)/(1 – 0.08) = 2,121.875`

4. `X = (0.08^-4 – 1)/(1 – 0.08) = 26,535.9375`

5. `X = (0.08^-5 – 1)/(1 – 0.08) = 331,711.71875`

6. `X = (0.08^-6 – 1)/(1 – 0.08) = 4,146,408.98437`

7. `X = (0.08^-7 – 1)/(1 – 0.08) = 51,830,124.8047`

8. `X = (0.08^-8 – 1)/(1 – 0.08) = 647,876,572.559`

What this means is to see for example 4 misses in a row, one on average would have to auto-attack 26 thousand and 536 times. It may happen sooner, or later, but on average that's the number of auto-attacks necessary.

What is also important to note, that it matter how we interpret our data. When searching for the clusters  we have to bear in mind that the formula only considers that a cluster is at least `n` long. For example it will predict how many times a cluster of two is formed, but it will say nothing about what happens after those two, only that we should have at least two (or more) in a row. So when searching I used
`miss` for a single miss, but ```hit miss miss``` for a double miss, and ```hit miss miss miss``` for a triple, to account for this. If you chose to do the same, make sure to check that your data starts with a hit, otherwise, these patterns might skip the first records you have and you will have to adjust for them manually.

So here is what we would expect to see emerging from the datasets, and what actually have emerged:

#### Dataset 1:

##### Expectations:
1. `3045 / 12.5 = 243.6`

2. `3045 / 168.75 = 18.0444444444`

3. `3045 / 2,121.875 = 1.43505154639`

4. `3045 / 26,535.9375 = 0.114750044162`

5. `3045 / 331,711.71875 = 0.0091796575999`

##### Results:

1. 235

2. 20

3. 4

4. 0

5. 0

#### Dataset 2:

##### Expectations:
1. `4008 / 12.5 = 320.64`

2. `4008 / 168.75 = 23.751111111111111111111111111111`

3. `4008 / 2,121.875 = 1.8888954344624447717231222385862`

4. `4008 / 26,535.9375 = 0.15104045221692280515809927574633`

5. `4008 / 331,711.71875 = 0.01208278084085625931779053253602`

##### Results:

1. 323

2. 23

3. 2

4. 0

5. 0

## Conclusion

Well shit. Seems like I have proven myself wrong and it was bias all along. Having 4, 3-long clusters in the first dataset is weird, hell, that was the reason for recording the second dataset, but given that pretty much everything else aligns with the predictions I'm happy to accept that it is just an anomaly. So yeah, there you go. If anyone feels the urge to follow in my footsteps feel free, and if you get stuck send me a message and I'll try to help. To me that seems conclusive enough.
