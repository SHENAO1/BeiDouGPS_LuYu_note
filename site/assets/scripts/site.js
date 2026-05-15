const yearNode = document.querySelector("[data-site-year]");

if (yearNode) {
  yearNode.textContent = String(new Date().getFullYear());
}

const filterButtons = [...document.querySelectorAll("[data-filter-button]")];
const filterCards = [...document.querySelectorAll("[data-filter-card]")];

if (filterButtons.length && filterCards.length) {
  const applyFilter = (value) => {
    filterButtons.forEach((button) => {
      button.classList.toggle("is-active", button.dataset.filterButton === value);
    });

    filterCards.forEach((card) => {
      const topics = (card.dataset.filterCard || "")
        .split(/\s+/)
        .filter(Boolean);
      const visible = value === "all" || topics.includes(value);
      card.classList.toggle("is-hidden", !visible);
    });
  };

  filterButtons.forEach((button) => {
    button.addEventListener("click", () => applyFilter(button.dataset.filterButton));
  });

  applyFilter("all");
}
