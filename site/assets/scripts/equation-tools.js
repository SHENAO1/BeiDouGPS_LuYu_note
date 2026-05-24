(function () {
  const DISPLAY_SELECTORS = ["span.math.display", "div.equation"];
  const TAG_PATTERN = /\\tag\*?\{([^}]*)\}/;

  function normalizeLabel(label) {
    const trimmed = (label || "").trim();
    if (!trimmed) return "(?)";
    return /^\(.+\)$/.test(trimmed) ? trimmed : "(" + trimmed + ")";
  }

  function extractDisplaySource(node) {
    const raw = (node.textContent || "").trim();
    if (!raw) return null;

    if (raw.startsWith("\\[") && raw.endsWith("\\]")) {
      return {
        open: "\\[",
        close: "\\]",
        body: raw.slice(2, -2).trim()
      };
    }

    if (raw.startsWith("$$") && raw.endsWith("$$")) {
      return {
        open: "$$",
        close: "$$",
        body: raw.slice(2, -2).trim()
      };
    }

    return null;
  }

  function preprocessDisplayMath() {
    const nodes = Array.from(document.querySelectorAll(DISPLAY_SELECTORS.join(",")));
    let autoIndex = 1;

    nodes.forEach((node) => {
      if (node.dataset.eqPrepared === "true") return;
      const source = extractDisplaySource(node);
      if (!source) return;

      const originalBody = source.body.trim();
      const tagMatch = originalBody.match(TAG_PATTERN);
      const displayBody = tagMatch ? originalBody.replace(TAG_PATTERN, "").trim() : originalBody;
      const label = tagMatch ? tagMatch[1].trim() : String(autoIndex++);

      node.dataset.eqPrepared = "true";
      node.dataset.eqLabel = normalizeLabel(label);
      node.dataset.eqCopySource = originalBody;
      node.textContent = source.open + "\n" + displayBody + "\n" + source.close;
    });
  }

  function fallbackCopy(text) {
    const field = document.createElement("textarea");
    field.value = text;
    field.setAttribute("readonly", "");
    field.style.position = "fixed";
    field.style.top = "-9999px";
    document.body.appendChild(field);
    field.select();
    const succeeded = document.execCommand("copy");
    document.body.removeChild(field);
    return succeeded;
  }

  async function copyLatex(text) {
    if (navigator.clipboard && navigator.clipboard.writeText) {
      await navigator.clipboard.writeText(text);
      return true;
    }

    return fallbackCopy(text);
  }

  function enhanceDisplayMath() {
    const nodes = Array.from(document.querySelectorAll(DISPLAY_SELECTORS.join(",")));

    nodes.forEach((node) => {
      if (!node.dataset.eqPrepared || node.dataset.eqEnhanced === "true") return;

      node.dataset.eqEnhanced = "true";
      node.classList.add("equation-card");

      const renderShell = document.createElement(node.tagName.toLowerCase() === "div" ? "div" : "span");
      renderShell.className = "equation-render";

      while (node.firstChild) {
        renderShell.appendChild(node.firstChild);
      }

      const number = document.createElement("span");
      number.className = "equation-number";
      number.textContent = node.dataset.eqLabel || "(?)";

      const button = document.createElement("button");
      button.type = "button";
      button.className = "equation-copy";
      button.textContent = "Copy LaTeX";
      button.setAttribute("aria-label", "复制公式 LaTeX 代码");
      button.addEventListener("click", async () => {
        try {
          await copyLatex(node.dataset.eqCopySource || "");
          button.textContent = "Copied";
          button.classList.add("is-copied");
          button.classList.remove("is-failed");
        } catch (error) {
          button.textContent = "Copy failed";
          button.classList.add("is-failed");
          button.classList.remove("is-copied");
        }

        window.clearTimeout(button._eqTimer);
        button._eqTimer = window.setTimeout(() => {
          button.textContent = "Copy LaTeX";
          button.classList.remove("is-copied", "is-failed");
        }, 1800);
      });

      node.appendChild(renderShell);
      node.appendChild(button);
      node.appendChild(number);
    });
  }

  const previousConfig = window.MathJax || {};
  const previousReady = previousConfig.startup && previousConfig.startup.ready;
  window.MathJax = Object.assign({}, previousConfig, {
    startup: Object.assign({}, previousConfig.startup, {
      ready: function () {
        preprocessDisplayMath();

        if (typeof previousReady === "function") {
          previousReady.apply(this, arguments);
        } else {
          MathJax.startup.defaultReady();
        }

        MathJax.startup.promise.then(function () {
          enhanceDisplayMath();
        });
      }
    })
  });

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", preprocessDisplayMath, { once: true });
  } else {
    preprocessDisplayMath();
  }
}());
