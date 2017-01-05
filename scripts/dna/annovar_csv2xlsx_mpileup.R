options(echo=FALSE)
args <- commandArgs(trailingOnly = TRUE)
print(args)
file <- args[1]

require(openxlsx)

csv <- read.csv(file, stringsAsFactors=FALSE)

if(nrow(csv) != 0) {
otherInfo <- paste("DP=", unlist(lapply(strsplit(csv$Otherinfo, "DP="), '[[', 2)), sep="")

info <- unlist(lapply(strsplit(otherInfo, "\t"), '[[', 1))
infoSplit <-strsplit(info, ";")
dp <- unlist(lapply(strsplit(unlist(lapply(strsplit(info, "DP="), '[[', 2)), ";"), '[[', 1))
dp4 <-unlist(lapply(strsplit(unlist(lapply(strsplit(info, "DP4="), '[[', 2)), ";"), '[[', 1))
mq <- unlist(lapply(strsplit(unlist(lapply(strsplit(info, "MQ="), '[[', 2)), ";"), '[[', 1))
fq <- unlist(lapply(strsplit(unlist(lapply(strsplit(info, "FQ="), '[[', 2)), ";"), '[[', 1))
af1 <- unlist(lapply(strsplit(unlist(lapply(strsplit(info, "AF1="), '[[', 2)), ";"), '[[', 1))
ac1 <- unlist(lapply(strsplit(unlist(lapply(strsplit(info, "AC1="), '[[', 2)), ";"), '[[', 1))
rest <-unlist(lapply(strsplit(unlist(lapply(strsplit(info, "AC1="), '[[', 2)), ";"), '[[', 2))
format <- unlist(lapply(strsplit(otherInfo, "\t"), '[[', 2))
sample <- unlist(lapply(strsplit(otherInfo, "\t"), '[[', 3))
sample <- gsub("nan,nan,nan", ".", sample)

out <- csv

af_list <- c()

for (i in dp4) {
  ref.for <- as.numeric(unlist(strsplit(i,split=","))[1])
  ref.rev <- as.numeric(unlist(strsplit(i,split=","))[2])
  alt.for <- as.numeric(unlist(strsplit(i,split=","))[3])
  alt.rev <- as.numeric(unlist(strsplit(i,split=","))[4])
  if (ref.for != 0 & ref.rev != 0) {
    ratioRef.for <- ref.for/(ref.for+ref.rev)
    ratioRef.rev <- ref.for/(ref.for+ref.rev)
    ratioAlt.for <- alt.for/(alt.for+alt.rev)
    ratioAlt.rev <- alt.rev/(alt.for+alt.rev)
    af <- (alt.for + alt.rev) /(ref.for+ref.rev+alt.for + alt.rev)
  }
  else {
  af <- 1
  }
  af_list<-c(af_list,af)
}

out$VAF <- af_list
out$DP <- dp
out$DP4 <- dp4
out$MQ <- mq
out$FQ <- fq
out$AF1 <- af1
out$AC1 <- ac1
out$Other <- rest
out$format <-format
out$sample <- sample
out <- out[,!(names(out) %in% c("Otherinfo"))]
out[is.na(out)] <- "NA"

#out <- out[,c(1:11,23:33,12:22)]

out.seq <- out
}
#} else
#{
#    cols <-  c("Chr", "Start", "End", "Ref", "Alt", "Func.refGene", "Gene.refGene", "ExonicFunc.refGene", "AAChange.refGene", "cytoBand", "snp138", "LJB_PhyloP", "LJB_PhyloP_Pred", "LJB_SIFT", "LJB_SIFT_Pred", "LJB_PolyPhen2", "LJB_PolyPhen2_Pred", "LJB_LRT", "LJB_LRT_Pred", "LJB_MutationTaster", "LJB_MutationTaster_Pred", "LJB_GERP..", "X1000g2012apr_all", "cosmic68", "Otherinfo")
#    out.seq <- as.data.frame(t(cols))[-1,]
#    colnames(out.seq) <- cols
#
#}

outFile <- paste(substr(file, 1, nchar(file)-3), "xlsx",sep="")
outFileCsv <- paste(substr(file, 1, nchar(file)-3), "_sort.csv",sep="")
write.csv2(out.seq, outFileCsv, row.names=FALSE)
write.xlsx(out.seq, file=outFile, rowNames=FALSE)
