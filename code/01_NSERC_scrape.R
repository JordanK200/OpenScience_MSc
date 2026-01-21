library(chromote)

b <- ChromoteSession$new()

# In a web browser, open a viewer for the headless browser.
b$view()

# Go to the NSERC Website
b$go_to("https://www.nserc-crsng.gc.ca/ase-oro/index_eng.asp")

# Wait 20 seconds for page to load
Sys.sleep(20)

# Select fiscal year dropdown
b$Runtime$evaluate("document.querySelector('button.ui-multiselect').click()")
Sys.sleep(2)

# Select 2012
b$Runtime$evaluate("document.querySelector('input[name=\"multiselect_fiscalyearfrom\"][value=\"2012\"]').click()")
Sys.sleep(2)

# Expand advanced search
b$Runtime$evaluate("document.querySelector('.toggle-link-expand')?.click()")
Sys.sleep(2)

# Select program drop down
b$Runtime$evaluate("document.querySelector('#program + button.ui-multiselect')?.click()")
Sys.sleep(2)

# Select "Discovery Grants Program - Individual"
b$Runtime$evaluate("document.querySelector('label[for=\"ui-multiselect-program-option-95\"]')?.click()")
Sys.sleep(2)

# Click the search button
b$Runtime$evaluate("document.querySelector('#buttonSearch')?.click()")
Sys.sleep(20)

# Expand the search results to show 200 per page
b$Runtime$evaluate("
const sel = document.querySelector('#result_length select');
sel.value = '200';
sel.dispatchEvent(new Event('change', {bubbles:true}));
")

Sys.sleep(20)

# JS snippet to grab the current page rows
get_rows_json <- "
(() => {
  const rows = Array.from(document.querySelectorAll('#result tbody tr'));
  const out = rows.map(tr => {
    const tds = Array.from(tr.querySelectorAll('td'));
    const link = tds[1]?.querySelector('a');
    return {
      name:   tds[0]?.innerText.trim() ?? null,
      title:  link?.innerText.trim() ?? tds[1]?.innerText.trim() ?? null,
      href:   link?.getAttribute('href') ?? null,
      amount: tds[2]?.innerText.trim() ?? null,
      year:   tds[3]?.innerText.trim() ?? null,
      program:tds[4]?.innerText.trim() ?? null
    };
  });
  return JSON.stringify(out);
})()
"

# Loop through all pages

all_pages <- list()
i <- 1

repeat {
  res <- b$Runtime$evaluate(get_rows_json, returnByValue = TRUE)
  page_df <- jsonlite::fromJSON(res$result$value)
  
  if (nrow(page_df) == 0) stop("No rows found.")
  
  all_pages[[i]] <- page_df
  message("Pages scraped: ", i, " | Rows total: ", sum(vapply(all_pages, nrow, 1L)))
  i <- i + 1
  
  nxt <- b$Runtime$evaluate("
(() => {
  const el = document.querySelector('#result_next');
  if (!el) return true;
  return el.classList.contains('paginate_button_disabled');
})()
")$result$value
  if (isTRUE(nxt)) break
  
  b$Runtime$evaluate("document.querySelector('#result_next')?.click()")
  Sys.sleep(5)
}

df <- do.call(rbind, all_pages)

write.csv(df, here::here("data", "raw-data", "RAW_NSERC.csv"))