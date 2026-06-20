import * as pdfjsLib from "pdfjs-dist";

pdfjsLib.GlobalWorkerOptions.workerSrc =
  "https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.worker.min.js";

export const parsePDF = async (file) => {
  console.log("🚀 parsePDF START");

  const buffer = await file.arrayBuffer();

  const pdf = await pdfjsLib.getDocument({ data: buffer }).promise;

  let text = "";

  for (let i = 1; i <= pdf.numPages; i++) {
    const page = await pdf.getPage(i);
    const content = await page.getTextContent();

    const pageText = content.items.map((item) => item.str).join(" ");
    text += pageText + "\n";
  }

  console.log("📄 RAW TEXT:", text);

  // 🔥 CLEAN TEXT
  text = text.replace(/\n/g, " ");
  text = text.replace(/\s+/g, " ");

  const header = extractHeader(text);
  const parts = extractParts(text);

  const finalData = { ...header, parts };

  console.log("✅ FINAL OUTPUT:", finalData);

  return finalData;
};


// ================= HEADER =================
const extractHeader = (text) => {
  const pickListNo =
    text.match(/Pick List No\s+([A-Z0-9-]+)/)?.[1] || "";

  const orderNoMatch =
    text.match(/Order No\s+([A-Z0-9-]+)\s+(\d+)/);

  const orderNo = orderNoMatch
    ? `${orderNoMatch[1]}${orderNoMatch[2]}`
    : "";

  const pickListDate =
    text.match(/Pick List Date\s+([\d/: ]+)/)?.[1]?.trim() || "";

  const orderDate =
    text.match(/Order Date\s+([\d/: ]+)/)?.[1]?.trim() || "";

  return {
    pickListNo,
    orderNo,
    pickListDate,
    orderDate,
  };
};


// ================= PARTS =================
const extractParts = (text) => {
  const parts = [];

  // ✅ Fix broken part numbers
  text = text.replace(/([A-Z0-9]{6,})\s+(1S)/g, "$1$2");
  text = text.replace(/([A-Z0-9]{6,})\s+S\b/g, "$1S");

  text = text.replace(/\s+/g, " ");

  const partRegex = /\b[A-Z0-9]*\d+[A-Z0-9]*(?:1S|S)\b/g;
  const matches = [...text.matchAll(partRegex)];

  matches.forEach((match) => {
    const partno = match[0];

    // 🚫 skip fake values
    if (!/\d/.test(partno)) return;

    const start = match.index + partno.length;

    // take chunk after part number
    const chunk = text.slice(start, start + 200);

    // 🔥 extract description (before HSN)
    const descMatch = chunk.match(/^(.+?)\s+\d{6,}/);

    const description = descMatch
      ? descMatch[1].trim()
      : "";

    // 🔥 extract numbers
    const nums = chunk.match(/[\d,]+\.\d+|\d+/g);

    if (!nums || nums.length < 5) return;

    let req_qty = 0;

    // ✅ find ORDER QTY (after MRP)
    for (let i = 0; i < nums.length; i++) {
      if (nums[i].includes(".")) {
        req_qty = Number(nums[i + 1]);
        break;
      }
    }

    parts.push({
      partno,
      description,
      req_qty,
    });
  });

  console.log("✅ FINAL PARTS WITH DESC:", parts);

  return parts;
};