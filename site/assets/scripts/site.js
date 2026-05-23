const yearNode = document.querySelector("[data-site-year]");

if (yearNode) {
  yearNode.textContent = String(new Date().getFullYear());
}

const normalizeNoteMathCode = () => {
  const noteProseBlocks = [...document.querySelectorAll(".note-prose")];
  if (!noteProseBlocks.length) return;

  const texCommandPattern =
    /\\(?:alpha|beta|Delta|delta|dfrac|dot|frac|hat|infty|int|left|lim|mathbb|mathcal|mathrm|neq|omega|Omega|pi|right|sin|cos|sum|tau|theta|Theta|tilde|to|zeta)(?![A-Za-z])/;
  const singleSymbolPattern = /^[A-Za-z](?:_[A-Za-z0-9{}]+)?(?:\([^)]+\))?$/;
  const compactMathPattern =
    /^(?:[A-Za-z0-9{}\\.^+\-*/=|()[\]\s,<>]+)$/;

  const shouldRenderAsMath = (value) => {
    const text = value.trim();
    if (!text) return false;
    if (/^site\//.test(text) || /\.html?$/.test(text) || /^Demo\s+\d/i.test(text)) return false;
    if (/^\\[\[(][\s\S]*\\[\])]$/.test(text)) return true;
    if (texCommandPattern.test(text)) return true;
    if (singleSymbolPattern.test(text)) return true;
    if (/[=^_]|(?:\b[HEF]\(s\)\b)|(?:\bB_n\b)|(?:\b\d+\/[A-Za-z]\b)|(?:\b[A-Za-z]\/[A-Za-z]\b)/.test(text)) {
      return compactMathPattern.test(text);
    }
    return false;
  };

  const toInlineMath = (value) => {
    const text = value.trim();
    if (/^\\\([\s\S]*\\\)$/.test(text) || /^\\\[[\s\S]*\\\]$/.test(text)) {
      return text;
    }
    return `\\(${text}\\)`;
  };

  noteProseBlocks.forEach((block) => {
    [...block.querySelectorAll("code")].forEach((codeNode) => {
      const text = codeNode.textContent || "";
      if (!shouldRenderAsMath(text)) return;
      codeNode.replaceWith(document.createTextNode(toInlineMath(text)));
    });
  });
};

normalizeNoteMathCode();

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

const syncScrollState = () => {
  document.body.classList.toggle("is-scrolled", window.scrollY > 24);
};

syncScrollState();
window.addEventListener("scroll", syncScrollState, { passive: true });

const revealNodes = [
  ...document.querySelectorAll(
    [
      ".hero-metrics article",
      ".module-card",
      ".note-feature",
      ".note-card",
      ".catalog-card",
      ".index-feature",
      ".video-feature",
      ".video-card",
      ".template-card",
      ".project-card",
      ".roadmap-card",
      ".about-card",
      ".module-bridge-card"
    ].join(",")
  )
];

if (revealNodes.length) {
  revealNodes.forEach((node, index) => {
    node.setAttribute("data-reveal", "");
    node.style.setProperty("--reveal-delay", `${(index % 4) * 70}ms`);
  });

  const prefersReducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  if (prefersReducedMotion || typeof IntersectionObserver === "undefined") {
    revealNodes.forEach((node) => node.classList.add("is-visible"));
  } else {
    const revealObserver = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add("is-visible");
            revealObserver.unobserve(entry.target);
          }
        });
      },
      {
        rootMargin: "0px 0px -12% 0px",
        threshold: 0.12
      }
    );

    revealNodes.forEach((node) => revealObserver.observe(node));
  }
}
