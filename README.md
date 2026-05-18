# cdiscmask

Some ideas for a R package:

- Create an R pacakge that specificaly anomynizes CDISC data
- There are pacakges like `deident` and `privacyR` that already does some of the work
- The `anonymize_dataframe` in `privacyR` is a good starting point but we need additional functionality
  - Currently AGE is anomynized from a number to a category. We want to preserve all original formats so numbers will have to stay numbers
  - We need to take into account relationships between different datasets; in case a date for a specifi ID is shifted in one dataset it should be shifted in the same way in other domains as well
  - We need to 'keep track' of the changes so we can also 'de-anomynize' and get the original data back again
  - We need to make sure that all sensitive data is found automatically and anomynized while less sensitive data like units, normal ranges, etc. are kept as is
  - We need to make sure that data can be fully analysed but no sensitive data will be present anymore


Some general ideas

- In the end we can use this package in an agentic workflow. Where data might be necessary to set-up new code but we do not want to share sensitive information
- There might be cases that source data is not available as CDISC data; in these cases it is important that we create CDISC as a pre-processing step
  for this we might want to have a separate R package in the future. Added value is that we can always start from CDISC, this makes it easier to create analysis datasets
  when all naming/format is standardized