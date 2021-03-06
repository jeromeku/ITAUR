## Demonstration of quanteda's capabilities
##
## Ken Benoit <kbenoit@lse.ac.uk>
## Paul Nulty <p.nulty@lse.ac.uk>

require(quanteda)

help(package="quanteda")

## create a corpus from a text vector of UK immigration texts
summary(ukimmigTexts)
str(ukimmigTexts)
encoding(ukimmigTexts)
encoding(encodedTexts)

# create a corpus from immigration texts
immigCorpus <- corpus(ukimmigTexts, notes="Created as part of a demo.")
docvars(immigCorpus) <- data.frame(party = docnames(immigCorpus), year = 2010)
summary(immigCorpus)

# explore using kwic
kwic(immigCorpus, "deport", window = 3)
kwic(immigCorpus, "illegal immig*", window = 3)

# extract a document-feature matrix
immigDfm <- dfm(subset(immigCorpus, party=="BNP"))
plot(immigDfm)
immigDfm <- dfm(subset(immigCorpus, party=="BNP"), ignoredFeatures = stopwords("english"))
plot(immigDfm, random.color = TRUE, rot.per = .25, colors = sample(colors()[2:128], 5))

# change units to sentences
immigCorpusSent <- changeunits(immigCorpus, to = "sentences")
summary(immigCorpusSent, 20)


## tokenize some texts
txt <- "#TextAnalysis is MY <3 4U @myhandle gr8 #stuff :-)"
tokenize(txt, removePunct=TRUE)
tokenize(txt, removePunct=TRUE, removeTwitter=TRUE)
(toks <- tokenize(toLower(txt), removePunct=TRUE, removeTwitter=TRUE))

# tokenize sentences
(sents <- tokenize(ukimmigTexts[3], what = "sentence", simplify = TRUE)[1:5])
# tokenize characters
tokenize(ukimmigTexts[1], what = "character", simplify = TRUE)[1:100]


## some descriptive statistics

## create a document-feature matrix from the inaugural corpus
summary(inaugCorpus)
presDfm <- dfm(inaugCorpus)
presDfm
docnames(presDfm)
# concatenate by president name                 
presDfm <- dfm(inaugCorpus, groups="President")
presDfm
docnames(presDfm)

# need first to install quantedaData, using
# devtools::install_github("kbenoit/quantedaData")
## show some selection capabilities on Irish budget corpus
data(iebudgetsCorpus, package = "quantedaData")
summary(iebudgetsCorpus, 10)
ieFinMin <- subset(iebudgetsCorpus, number=="01" & debate == "BUDGET")
summary(ieFinMin)
dfmFM <- dfm(ieFinMin)
plot(2008:2012, lexdiv(dfmFM, "C"), xlab="Year", ylab="Herndan's C", type="b",
     main = "World's Crudest Lexical Diversity Plot")


# plot some readability statistics
data(SOTUCorpus, package = "quantedaData")
fk <- readability(SOTUCorpus, "Flesch.Kincaid")
year <- lubridate::year(docvars(SOTUCorpus, "Date"))
require(ggplot2)
partyColours <- c("blue", "blue", "black", "black", "red", "red")
p <- ggplot(data = docvars(SOTUCorpus), aes(x = year, y = fk)) + #, group = delivery)) +
    theme(panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_blank(),
          axis.line = element_line(colour = "black")) +
    geom_smooth(alpha=0.2, linetype=1, color="grey70", method = "loess", span = .34) +
    xlab("") +
    ylab("Flesch-Kincaid") +
    geom_point(aes(colour = party)) +
    scale_colour_manual(values = partyColours) +
    geom_line(aes(), alpha=0.3, size = 1) +
    ggtitle("Text Complexity in State of the Union Addresses") + 
    theme(plot.title = element_text(lineheight=.8, face="bold"))
quartz(height=7, width=12)
print(p)


## Presidential Inaugural Address Corpus
presDfm <- dfm(inaugCorpus, ignoredFeatures = stopwords("english"))
# compute some document similarities
(docsim <- similarity(presDfm, "1985-Reagan", n=5, margin="documents"))
as.matrix(docsim)

similarity(presDfm, c("2009-Obama" , "2013-Obama"), n=5, margin="documents", method = "cosine")
similarity(presDfm, c("2009-Obama" , "2013-Obama"), n=5, margin="documents", method = "Hellinger")
similarity(presDfm, c("2009-Obama" , "2013-Obama"), n=5, margin="documents", method = "eJaccard")

# compute some term similarities
featsim <- similarity(presDfm, c("fair", "health", "terror"), margin = "features", 
                      method="cosine")
lapply(featsim, head)

## mining collocations

# form ngrams
txt <- "Hey @kenbenoit #textasdata: The quick, brown fox jumped over the lazy dog!"
(toks1 <- tokenize(toLower(txt), removePunct = TRUE))
tokenize(toLower(txt), removePunct = TRUE, ngrams = 2)
tokenize(toLower(txt), removePunct = TRUE, ngrams = c(1,3))

# low-level options exist too
ngrams(toks1, c(1, 3, 5))

# form "skip-grams"
tokens <- tokenize(toLower("Insurgents killed in ongoing fighting."),
                   removePunct = TRUE, simplify = TRUE)
skipgrams(tokens, n = 2, skip = 0:1, concatenator = " ") 
skipgrams(tokens, n = 2, skip = 0:2, concatenator = " ") 
skipgrams(tokens, n = 3, skip = 0:2, concatenator = " ") 

# mine bigrams
collocs2 <- collocations(inaugTexts, size = 2, method = "all")
head(collocs2, 20)

# mine trigrams
collocs3 <- collocations(inaugTexts, size = 3, method = "all")
head(collocs3, 20)

# remove parts of speech and inspect
head(removeFeatures(collocs2, stopwords("english")), 20)
head(removeFeatures(collocs3, stopwords("english")), 20)

