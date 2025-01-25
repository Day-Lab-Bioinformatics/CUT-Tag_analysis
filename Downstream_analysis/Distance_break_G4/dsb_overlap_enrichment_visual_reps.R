# Author: Annika Salpukas
# Date: September 2024

library(ggplot2)
library(grid)
library(gridExtra)
library(dplyr)
library(parallel)

file = '/path/to/data/specific_positions_scaled_reps.csv'
sfile = '/path/to/shuffled/data/specific_positions_scaled_reps_shuffle.csv'

ex_df <- read.csv(file, stringsAsFactors = FALSE)
ex_df$Group <- 'Experimental' 

shuffle_df <- read.csv(sfile, stringsAsFactors = FALSE)
shuffle_df$Group <- 'Shuffle'

df <- merge(ex_df, shuffle_df, by=c('Gene', 'Element', 'Rep', 'DSB.Position'), sort=F)

gene <- 'siControl_BRACO19_18h'
outpath <- paste0('/path/to/data/',
                  gene, '-dsb-enrichment-scaled-final.svg')

df <- df[df$Element != 'Non-canonical' & df$Gene == gene,]
df$Element = replace(df$Element, df$Element=='Before', 'Upstream') 
df$Element = replace(df$Element, df$Element=='After', 'Downstream') 
df$Enrichment <- df$Frequency.x / df$Frequency.y

filtered_df <- df %>%
  group_by(Gene, Element, DSB.Position) %>%
  filter(n() >= 3) %>%
  ungroup()

unique_combinations <- filtered_df %>%
  distinct(Gene, Element, DSB.Position)
unique_combinations <- split(unique_combinations, seq(nrow(unique_combinations)))

t_test <- function(row) {
  gene_val <- row$Gene
  element_val <- row$Element
  dsb_position_val <- row$DSB.Position
  
  temp <- filtered_df %>%
    filter(Gene == gene_val, Element == element_val, DSB.Position == dsb_position_val)
  
  mean_enrichment <- mean(temp$Enrichment)
  
  tryCatch({
    p_val <- t.test(temp$Frequency.x, temp$Frequency.y, paired = TRUE)$p.value
    return(c(gene_val, element_val, dsb_position_val, mean_enrichment, p_val))
  }, error = function(e) {
    return(c(gene_val, element_val, dsb_position_val, mean_enrichment, NA))
  })
}
#results <- mclapply(unique_combinations, t_test, mc.cores = detectCores()-1)
results <- lapply(unique_combinations, t_test)

df_stats <- do.call(rbind, results)
df_stats <- as.data.frame(df_stats, stringsAsFactors = FALSE)
names(df_stats) <- c('Gene', 'Element', 'DSB.Position', 'Mean.Enrichment', 'P.Val')
df_stats$DSB.Position <- as.numeric(df_stats$DSB.Position)
df_stats$Mean.Enrichment <- as.numeric(df_stats$Mean.Enrichment)

df <- filtered_df %>%
  left_join(df_stats, by = c('Gene', 'Element', 'DSB.Position'))
df$Sig <- ifelse(df$P.Val < 0.05,
                 TRUE,
                 FALSE)

df <- df %>%
  mutate(Sig = ifelse(is.na(Sig), FALSE, Sig))

#df <- df %>%
#  mutate(SigFC = case_when(
#    Sig == TRUE & (Mean.Enrichment <= 0.5 | Mean.Enrichment >= 1.5) ~ 2,
#    Sig == TRUE ~ 1,
#    TRUE ~ 0
#  ))

df <- df %>%
  mutate(SigFC = ifelse(
    Sig == TRUE & (Mean.Enrichment <= 0.5 | Mean.Enrichment >= 1.5
                   ), TRUE, FALSE))


plots <- list()
theme_set(theme_classic(base_family = "Arial"))
for (element in unique(df$Element)) {
  df_element <- df[df$Element == element,]
  
  if (element == 'Upstream') {
    custom_theme <- theme(legend.position="none")
  } else {
    custom_theme <- theme(axis.title.y=element_blank(),
                          axis.text.y=element_blank(),
                          axis.ticks.y=element_blank(),
                          axis.line.y=element_blank(),
                          legend.position='none')
  }
  
  #sig_positions <- unique(df_element$DSB.Position[df_element$Sig == TRUE])
  p <- ggplot(df_element, aes(x=DSB.Position, y=Mean.Enrichment, color=SigFC)) + 
    #geom_vline(xintercept = sig_positions, color = "grey", linewidth = 1.5, alpha = 0.5) +
    geom_point(size=1.5, alpha=1) +
    scale_color_manual(values=c('grey', 'blue')) +
    labs(x=element, y='Mean Enrichment') +
    ylim(0, 3) +
    theme_classic() +
    custom_theme +
    theme(
      text = element_text(family = "Arial"),
      plot.title = element_text(family = "Arial", size = 14, face = "bold"),
      axis.title = element_text(family = "Arial", size = 12),
      axis.text = element_text(family = "Arial", size = 10)
    )
  
  if (element != 'Upstream' & element != 'Downstream') {
    p <- p + scale_x_continuous(breaks=seq(0,1,by=0.5), limits=c(0,1))
  }
  plots[[length(plots) + 1]] <- p
}
plot_widths = c(2, 1, 1.5, 1, 1.5, 1, 1.5, 1, 2)

title <- paste0("DSB Position Frequencies Proximal to G4s (", gene, ")")
g <- arrangeGrob(grobs = plots, ncol = length(plots), widths = unit(plot_widths, "null"),
                 top=textGrob(title))
ggsave(filename = outpath, 
       plot = g, width = sum(unlist(plot_widths)), height = 4, dpi = 300)
