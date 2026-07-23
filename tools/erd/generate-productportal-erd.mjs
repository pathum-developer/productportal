#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";

const DEFAULT_INPUT = "backups/productportal-schema.sql";
const DEFAULT_OUTPUT = "docs/database/productportal-er-diagram.svg";
const EXCLUDED_TABLES = new Set([
  "databasechangelog",
  "databasechangeloglock",
  "flyway_schema_history",
]);

const EXPECTED_DOMAIN_TABLES = 23;
const EXPECTED_FOREIGN_KEYS = 23;
const EXPECTED_NULLABLE_FOREIGN_KEY_COLUMNS = 5;

const CANVAS = { width: 7680, height: 3600 };
const CARD = { headerHeight: 52, rowHeight: 29, defaultWidth: 560 };

const GROUPS = [
  {
    name: "Access & Authorization",
    description: "Roles, permissions, scoped grants and organization-aware assignments",
    x: 50,
    y: 270,
    width: 2220,
    height: 2250,
    accent: "#0284c7",
    fill: "#f2f9fe",
  },
  {
    name: "Identity, Organization & Authentication",
    description: "Users, memberships, sessions, addresses and login protection",
    x: 2310,
    y: 270,
    width: 2860,
    height: 2250,
    accent: "#2563eb",
    fill: "#f4f7ff",
  },
  {
    name: "Catalog",
    description: "Products, categories, brands and lifecycle reference data",
    x: 5210,
    y: 270,
    width: 2420,
    height: 2250,
    accent: "#0891b2",
    fill: "#f1fbfc",
  },
  {
    name: "Audit History",
    description: "Trigger-maintained history tables; intentionally isolated from the physical FK graph",
    x: 50,
    y: 2570,
    width: 7580,
    height: 900,
    accent: "#64748b",
    fill: "#f8fafc",
  },
];

const LAYOUT = {
  pp_m_role: { x: 100, y: 420 },
  pp_m_permission: { x: 100, y: 950 },
  pp_r_permission_scope: { x: 100, y: 1580 },
  pp_t_role_permission_grant: { x: 800, y: 690, width: 610 },
  pp_t_user_role_assignment: { x: 1540, y: 1120, width: 650 },

  pp_m_organization: { x: 2360, y: 400, width: 610 },
  pp_r_membership_status: { x: 2360, y: 1040, width: 610 },
  pp_r_user_status: { x: 2360, y: 1640, width: 610 },
  pp_t_user_organization_membership: { x: 3040, y: 540, width: 650 },
  pp_m_user: { x: 3740, y: 650, width: 650 },
  pp_m_user_address: { x: 4470, y: 350, width: 640 },
  pp_t_auth_session: { x: 4470, y: 990, width: 640 },
  pp_a_login_attempt: { x: 4470, y: 1640, width: 640 },
  pp_t_login_throttle_state: { x: 3040, y: 1510, width: 650 },

  pp_r_category_status: { x: 5260, y: 400 },
  pp_r_brand_status: { x: 5260, y: 1030 },
  pp_r_product_status: { x: 5260, y: 1660 },
  pp_m_category: { x: 5900, y: 350, width: 600 },
  pp_m_brand: { x: 5900, y: 1010, width: 600 },
  pp_m_product: { x: 6630, y: 650, width: 650 },

  pp_t_role_permission_grant_audit: { x: 180, y: 2750, width: 2150 },
  pp_t_user_organization_membership_audit: { x: 2590, y: 2750, width: 2210 },
  pp_t_user_role_assignment_audit: { x: 5060, y: 2750, width: 2390 },
};

function parseArguments(argv) {
  const options = { input: DEFAULT_INPUT, output: DEFAULT_OUTPUT };
  for (let index = 0; index < argv.length; index += 1) {
    const argument = argv[index];
    if (argument === "--input") {
      options.input = requireValue(argv, ++index, argument);
    } else if (argument === "--output") {
      options.output = requireValue(argv, ++index, argument);
    } else if (argument === "--help" || argument === "-h") {
      printUsage();
      process.exit(0);
    } else {
      throw new Error(`Unknown argument: ${argument}`);
    }
  }
  return options;
}

function requireValue(argv, index, option) {
  if (index >= argv.length || argv[index].startsWith("--")) {
    throw new Error(`Missing value for ${option}`);
  }
  return argv[index];
}

function printUsage() {
  console.log(`Usage: node tools/erd/generate-productportal-erd.mjs [options]\n\n` +
    `Options:\n` +
    `  --input <path>   PostgreSQL pg_dump schema (default: ${DEFAULT_INPUT})\n` +
    `  --output <path>  SVG destination (default: ${DEFAULT_OUTPUT})\n` +
    `  -h, --help       Show this help`);
}

function parseSchema(sql) {
  const normalized = sql.replace(/\r\n/g, "\n");
  const tables = new Map();
  const tablePattern = /CREATE TABLE public\.([a-zA-Z0-9_]+) \(\n([\s\S]*?)\n\);/g;

  for (const match of normalized.matchAll(tablePattern)) {
    const name = match[1];
    if (EXCLUDED_TABLES.has(name)) {
      continue;
    }

    const columns = [];
    for (const sourceLine of match[2].split("\n")) {
      const line = sourceLine.trim().replace(/,$/, "");
      if (!line || line.startsWith("CONSTRAINT ")) {
        continue;
      }

      const columnMatch = /^([a-zA-Z_][a-zA-Z0-9_]*)\s+(.+)$/.exec(line);
      if (!columnMatch) {
        throw new Error(`Cannot parse column in ${name}: ${line}`);
      }

      const definition = columnMatch[2];
      columns.push({
        name: columnMatch[1],
        type: normalizeType(definition),
        notNull: /\bNOT NULL\b/i.test(definition),
        primaryKey: false,
        foreignKey: false,
        unique: false,
      });
    }

    tables.set(name, {
      name,
      columns,
      primaryKey: [],
      uniqueKeys: [],
      foreignKeys: [],
    });
  }

  const primaryKeyPattern = /ALTER TABLE ONLY public\.([a-zA-Z0-9_]+)\s+ADD CONSTRAINT\s+\S+\s+PRIMARY KEY\s+\(([^)]+)\);/g;
  for (const match of normalized.matchAll(primaryKeyPattern)) {
    const table = tables.get(match[1]);
    if (!table) {
      continue;
    }
    table.primaryKey = parseColumnList(match[2]);
  }

  const uniqueKeyPattern = /ALTER TABLE ONLY public\.([a-zA-Z0-9_]+)\s+ADD CONSTRAINT\s+\S+\s+UNIQUE\s+\(([^)]+)\);/g;
  for (const match of normalized.matchAll(uniqueKeyPattern)) {
    const table = tables.get(match[1]);
    if (!table) {
      continue;
    }
    table.uniqueKeys.push(parseColumnList(match[2]));
  }

  const foreignKeys = [];
  const foreignKeyPattern = /ALTER TABLE ONLY public\.([a-zA-Z0-9_]+)\s+ADD CONSTRAINT\s+(\S+)\s+FOREIGN KEY\s+\(([^)]+)\)\s+REFERENCES\s+public\.([a-zA-Z0-9_]+)\(([^)]+)\)([^;]*);/g;
  for (const match of normalized.matchAll(foreignKeyPattern)) {
    const childTable = tables.get(match[1]);
    const parentTable = tables.get(match[4]);
    if (!childTable || !parentTable) {
      continue;
    }

    const childColumns = parseColumnList(match[3]);
    const parentColumns = parseColumnList(match[5]);
    const deleteMatch = /ON DELETE\s+(CASCADE|SET NULL|SET DEFAULT|RESTRICT|NO ACTION)/i.exec(match[6]);
    const foreignKey = {
      name: match[2],
      childTable: childTable.name,
      childColumns,
      parentTable: parentTable.name,
      parentColumns,
      deleteAction: deleteMatch ? deleteMatch[1].toUpperCase() : "NO ACTION",
    };
    childTable.foreignKeys.push(foreignKey);
    foreignKeys.push(foreignKey);
  }

  for (const table of tables.values()) {
    const foreignKeyColumns = new Set(table.foreignKeys.flatMap((key) => key.childColumns));
    const uniqueColumns = new Set(table.uniqueKeys.flat());
    for (const column of table.columns) {
      column.primaryKey = table.primaryKey.includes(column.name);
      column.foreignKey = foreignKeyColumns.has(column.name);
      column.unique = uniqueColumns.has(column.name);
    }
  }

  return { tables, foreignKeys };
}

function normalizeType(definition) {
  let type = definition
    .replace(/\s+DEFAULT\s+[\s\S]*$/i, "")
    .replace(/\s+NOT NULL\b/gi, "")
    .trim();
  return type
    .replace(/^character varying/i, "varchar")
    .replace(/^character\(/i, "char(")
    .replace(/timestamp\((\d+)\) without time zone/i, "timestamp($1)")
    .replace(/timestamp without time zone/i, "timestamp")
    .replace(/timestamp\((\d+)\) with time zone/i, "timestamptz($1)")
    .replace(/timestamp with time zone/i, "timestamptz");
}

function parseColumnList(value) {
  return value.split(",").map((column) => column.trim().replace(/^"|"$/g, ""));
}

function validateModel(model) {
  const errors = [];
  if (model.tables.size !== EXPECTED_DOMAIN_TABLES) {
    errors.push(`Expected ${EXPECTED_DOMAIN_TABLES} domain tables, parsed ${model.tables.size}`);
  }
  if (model.foreignKeys.length !== EXPECTED_FOREIGN_KEYS) {
    errors.push(`Expected ${EXPECTED_FOREIGN_KEYS} foreign keys, parsed ${model.foreignKeys.length}`);
  }

  const nullableForeignKeyColumns = new Set();
  for (const foreignKey of model.foreignKeys) {
    const child = requireTable(model, foreignKey.childTable);
    for (const columnName of foreignKey.childColumns) {
      const column = requireColumn(child, columnName);
      if (!column.notNull) {
        nullableForeignKeyColumns.add(`${child.name}.${column.name}`);
      }
    }
    const parent = requireTable(model, foreignKey.parentTable);
    foreignKey.parentColumns.forEach((columnName) => requireColumn(parent, columnName));
  }

  if (nullableForeignKeyColumns.size !== EXPECTED_NULLABLE_FOREIGN_KEY_COLUMNS) {
    errors.push(
      `Expected ${EXPECTED_NULLABLE_FOREIGN_KEY_COLUMNS} nullable FK columns, parsed ` +
      `${nullableForeignKeyColumns.size}: ${[...nullableForeignKeyColumns].join(", ")}`,
    );
  }

  const modelTables = new Set(model.tables.keys());
  const layoutTables = new Set(Object.keys(LAYOUT));
  const missingLayout = [...modelTables].filter((name) => !layoutTables.has(name));
  const staleLayout = [...layoutTables].filter((name) => !modelTables.has(name));
  if (missingLayout.length > 0) {
    errors.push(`Missing layout entries: ${missingLayout.join(", ")}`);
  }
  if (staleLayout.length > 0) {
    errors.push(`Layout contains unknown tables: ${staleLayout.join(", ")}`);
  }

  if (errors.length > 0) {
    throw new Error(`Schema validation failed:\n- ${errors.join("\n- ")}`);
  }
}

function requireTable(model, name) {
  const table = model.tables.get(name);
  if (!table) {
    throw new Error(`Unknown table: ${name}`);
  }
  return table;
}

function requireColumn(table, name) {
  const column = table.columns.find((candidate) => candidate.name === name);
  if (!column) {
    throw new Error(`Unknown column: ${table.name}.${name}`);
  }
  return column;
}

function enrichLayout(model) {
  for (const table of model.tables.values()) {
    const configured = LAYOUT[table.name];
    table.x = configured.x;
    table.y = configured.y;
    table.width = configured.width ?? CARD.defaultWidth;
    table.height = CARD.headerHeight + table.columns.length * CARD.rowHeight;
  }
}

function renderSvg(model, sourcePath) {
  const output = [];
  output.push(`<?xml version="1.0" encoding="UTF-8"?>`);
  output.push(`<svg xmlns="http://www.w3.org/2000/svg" width="${CANVAS.width}" height="${CANVAS.height}" viewBox="0 0 ${CANVAS.width} ${CANVAS.height}" role="img" aria-labelledby="title description">`);
  output.push(`<title id="title">Product Portal physical entity relationship diagram</title>`);
  output.push(`<desc id="description">Twenty-three application tables and twenty-three PostgreSQL foreign-key relationships parsed from ${escapeXml(sourcePath)}.</desc>`);
  output.push(`<defs>`);
  output.push(`<filter id="cardShadow" x="-15%" y="-15%" width="130%" height="140%"><feDropShadow dx="0" dy="5" stdDeviation="7" flood-color="#0f2740" flood-opacity="0.13"/></filter>`);
  output.push(`<style><![CDATA[
    .title { font: 700 44px 'Segoe UI', Arial, sans-serif; fill: #102a43; }
    .subtitle { font: 400 20px 'Segoe UI', Arial, sans-serif; fill: #52677d; }
    .legend { font: 500 17px 'Segoe UI', Arial, sans-serif; fill: #314a61; }
    .group-title { font: 700 25px 'Segoe UI', Arial, sans-serif; }
    .group-description { font: 400 16px 'Segoe UI', Arial, sans-serif; fill: #60758a; }
    .table-name { font: 700 19px 'Segoe UI', Arial, sans-serif; fill: #0f3655; }
    .column { font: 400 15px 'Cascadia Mono', Consolas, monospace; fill: #17324d; }
    .column-required { font: 600 15px 'Cascadia Mono', Consolas, monospace; fill: #102a43; }
    .type { font: 400 14px 'Cascadia Mono', Consolas, monospace; fill: #6a7f92; }
    .badge { font: 700 11px 'Segoe UI', Arial, sans-serif; fill: white; letter-spacing: .2px; }
    .cardinality { font: 700 14px 'Segoe UI', Arial, sans-serif; fill: #075985; }
    .footer { font: 400 15px 'Segoe UI', Arial, sans-serif; fill: #66788a; }
  ]]></style>`);
  output.push(`</defs>`);

  output.push(`<rect x="0" y="0" width="${CANVAS.width}" height="${CANVAS.height}" fill="#ffffff"/>`);
  output.push(`<rect x="0" y="0" width="${CANVAS.width}" height="220" fill="#f8fbfe"/>`);
  output.push(`<text x="70" y="75" class="title">Product Portal — Physical Entity–Relationship Diagram</text>`);
  output.push(`<text x="72" y="118" class="subtitle">PostgreSQL 17 • public schema • 23 application tables • 23 physical foreign keys • source: ${escapeXml(toPortablePath(sourcePath))}</text>`);
  output.push(`<text x="72" y="151" class="subtitle">Migration metadata excluded: databasechangelog, databasechangeloglock, flyway_schema_history</text>`);
  output.push(renderLegend());

  for (const group of GROUPS) {
    output.push(renderGroup(group));
  }

  for (const foreignKey of model.foreignKeys) {
    output.push(renderRelationship(model, foreignKey));
  }

  for (const table of model.tables.values()) {
    output.push(renderTable(table));
  }

  output.push(`<text x="80" y="3555" class="footer">Cardinality is shown from each endpoint’s perspective. Solid FK = identifying (FK columns participate in child PK); dashed FK = non-identifying. Audit history tables define no physical foreign keys.</text>`);
  output.push(`<text x="7600" y="3555" class="footer" text-anchor="end">Generated deterministically from PostgreSQL DDL</text>`);
  output.push(`</svg>`);
  return output.join("\n");
}

function renderLegend() {
  const items = [];
  let x = 3540;
  const y = 82;

  items.push(`<g transform="translate(${x},${y})">`);
  items.push(`<rect x="0" y="-25" width="4060" height="105" rx="16" fill="#ffffff" stroke="#d9e8f2"/>`);
  items.push(`<text x="24" y="8" class="legend" font-weight="700">Legend</text>`);
  items.push(`<rect x="104" y="-10" width="33" height="22" rx="5" fill="#f59e0b"/><text x="120.5" y="6" class="badge" text-anchor="middle">PK</text>`);
  items.push(`<text x="148" y="7" class="legend">primary key</text>`);
  items.push(`<rect x="290" y="-10" width="33" height="22" rx="5" fill="#0284c7"/><text x="306.5" y="6" class="badge" text-anchor="middle">FK</text>`);
  items.push(`<text x="334" y="7" class="legend">foreign key</text>`);
  items.push(`<rect x="480" y="-10" width="36" height="22" rx="5" fill="#7c3aed"/><text x="498" y="6" class="badge" text-anchor="middle">UQ</text>`);
  items.push(`<text x="528" y="7" class="legend">unique-key member</text>`);
  items.push(`<path d="M 748 0 H 855" stroke="#0284c7" stroke-width="4"/><text x="870" y="7" class="legend">identifying FK</text>`);
  items.push(`<path d="M 1045 0 H 1152" stroke="#0284c7" stroke-width="3" stroke-dasharray="10 8"/><text x="1167" y="7" class="legend">non-identifying FK</text>`);
  items.push(`<text x="1475" y="7" class="legend"><tspan font-weight="700">1</tspan> required parent</text>`);
  items.push(`<text x="1675" y="7" class="legend"><tspan font-weight="700">0..1</tspan> optional parent</text>`);
  items.push(`<text x="1905" y="7" class="legend"><tspan font-weight="700">0..*</tspan> child rows</text>`);
  items.push(`<text x="24" y="49" class="legend">Bold column = NOT NULL</text>`);
  items.push(`<text x="235" y="49" class="legend">•</text><text x="256" y="49" class="legend">Connector anchors correspond to the actual FK/PK column rows</text>`);
  items.push(`<text x="855" y="49" class="legend">•</text><text x="876" y="49" class="legend">Audit cards are present but physically disconnected</text>`);
  items.push(`<text x="1400" y="49" class="legend">•</text><text x="1421" y="49" class="legend">No true 1:1 relationship exists in this schema</text>`);
  items.push(`</g>`);
  return items.join("");
}

function renderGroup(group) {
  return `<g>` +
    `<rect x="${group.x}" y="${group.y}" width="${group.width}" height="${group.height}" rx="24" fill="${group.fill}" stroke="${group.accent}" stroke-opacity="0.25" stroke-width="2"/>` +
    `<rect x="${group.x}" y="${group.y}" width="9" height="${group.height}" rx="4" fill="${group.accent}" fill-opacity="0.78"/>` +
    `<text x="${group.x + 30}" y="${group.y + 43}" class="group-title" fill="${group.accent}">${escapeXml(group.name)}</text>` +
    `<text x="${group.x + 30}" y="${group.y + 72}" class="group-description">${escapeXml(group.description)}</text>` +
    `</g>`;
}

function renderRelationship(model, foreignKey) {
  const child = requireTable(model, foreignKey.childTable);
  const parent = requireTable(model, foreignKey.parentTable);
  const childColumnIndex = child.columns.findIndex((column) => column.name === foreignKey.childColumns[0]);
  const parentColumnIndex = parent.columns.findIndex((column) => column.name === foreignKey.parentColumns[0]);
  const childColumn = child.columns[childColumnIndex];
  const requiredParent = foreignKey.childColumns.every((columnName) => requireColumn(child, columnName).notNull);
  const identifying = foreignKey.childColumns.every((columnName) => child.primaryKey.includes(columnName));
  const childTupleUnique = isUniqueTuple(child, foreignKey.childColumns);

  if (child.name === parent.name) {
    return renderSelfRelationship(child, childColumnIndex, parentColumnIndex, requiredParent, identifying);
  }

  const childCenterX = child.x + child.width / 2;
  const parentCenterX = parent.x + parent.width / 2;
  const childOnLeft = childCenterX < parentCenterX;
  const childX = childOnLeft ? child.x + child.width : child.x;
  const parentX = childOnLeft ? parent.x : parent.x + parent.width;
  const childY = rowCenter(child, childColumnIndex);
  const parentY = rowCenter(parent, parentColumnIndex);
  const horizontalDistance = Math.abs(parentX - childX);
  const control = Math.max(90, Math.min(330, horizontalDistance * 0.34));
  const childControlX = childX + (childOnLeft ? control : -control);
  const parentControlX = parentX + (childOnLeft ? -control : control);
  const lineStyle = identifying
    ? `stroke="#0284c7" stroke-width="4"`
    : `stroke="#0284c7" stroke-width="3" stroke-dasharray="11 9"`;
  const path = `M ${childX} ${childY} C ${childControlX} ${childY}, ${parentControlX} ${parentY}, ${parentX} ${parentY}`;

  const childCardinality = childTupleUnique ? "0..1" : "0..*";
  const parentCardinality = requiredParent ? "1" : "0..1";
  const childLabelX = childX + (childOnLeft ? 22 : -58);
  const parentLabelX = parentX + (childOnLeft ? -58 : 22);

  return `<g opacity="0.92">` +
    `<path d="${path}" fill="none" ${lineStyle}/>` +
    `<circle cx="${childX}" cy="${childY}" r="6" fill="#0284c7"/>` +
    `<circle cx="${parentX}" cy="${parentY}" r="7" fill="#ffffff" stroke="#0284c7" stroke-width="3"/>` +
    renderCardinalityLabel(childLabelX, childY - 19, childCardinality) +
    renderCardinalityLabel(parentLabelX, parentY - 19, parentCardinality) +
    `</g>`;
}

function renderSelfRelationship(table, childColumnIndex, parentColumnIndex, requiredParent, identifying) {
  const startX = table.x + table.width;
  const startY = rowCenter(table, childColumnIndex);
  const endX = table.x + table.width;
  const endY = rowCenter(table, parentColumnIndex);
  const loopX = table.x + table.width + 115;
  const upperY = Math.min(startY, endY) - 80;
  const lineStyle = identifying
    ? `stroke="#0284c7" stroke-width="4"`
    : `stroke="#0284c7" stroke-width="3" stroke-dasharray="11 9"`;
  const path = `M ${startX} ${startY} C ${loopX} ${startY}, ${loopX} ${upperY}, ${loopX} ${upperY} ` +
    `C ${loopX} ${upperY}, ${loopX} ${endY}, ${endX} ${endY}`;

  return `<g opacity="0.92">` +
    `<path d="${path}" fill="none" ${lineStyle}/>` +
    `<circle cx="${startX}" cy="${startY}" r="6" fill="#0284c7"/>` +
    `<circle cx="${endX}" cy="${endY}" r="7" fill="#ffffff" stroke="#0284c7" stroke-width="3"/>` +
    renderCardinalityLabel(startX + 18, startY - 19, "0..*") +
    renderCardinalityLabel(endX + 18, endY - 19, requiredParent ? "1" : "0..1") +
    `</g>`;
}

function renderCardinalityLabel(x, y, text) {
  const width = text.length <= 1 ? 31 : 51;
  return `<g><rect x="${x - 5}" y="${y - 16}" width="${width}" height="23" rx="6" fill="#ffffff" fill-opacity="0.94" stroke="#b9dbea"/>` +
    `<text x="${x + width / 2 - 5}" y="${y + 1}" class="cardinality" text-anchor="middle">${escapeXml(text)}</text></g>`;
}

function isUniqueTuple(table, columns) {
  return sameTuple(table.primaryKey, columns) || table.uniqueKeys.some((key) => sameTuple(key, columns));
}

function sameTuple(left, right) {
  return left.length === right.length && left.every((value, index) => value === right[index]);
}

function rowCenter(table, columnIndex) {
  return table.y + CARD.headerHeight + columnIndex * CARD.rowHeight + CARD.rowHeight / 2;
}

function renderTable(table) {
  const auditTable = table.name.endsWith("_audit");
  const headerAccent = auditTable ? "#64748b" : "#0b8ec8";
  const headerFill = auditTable ? "#eef2f6" : "#e7f6fd";
  const borderColor = auditTable ? "#94a3b8" : "#0794cf";
  const output = [];

  output.push(`<g filter="url(#cardShadow)">`);
  output.push(`<rect x="${table.x}" y="${table.y}" width="${table.width}" height="${table.height}" rx="10" fill="#ffffff" stroke="${borderColor}" stroke-width="2.5"/>`);
  output.push(`<path d="M ${table.x + 10} ${table.y} H ${table.x + table.width - 10} Q ${table.x + table.width} ${table.y} ${table.x + table.width} ${table.y + 10} V ${table.y + CARD.headerHeight} H ${table.x} V ${table.y + 10} Q ${table.x} ${table.y} ${table.x + 10} ${table.y}" fill="${headerFill}"/>`);
  output.push(`<rect x="${table.x}" y="${table.y}" width="8" height="${CARD.headerHeight}" rx="4" fill="${headerAccent}"/>`);
  output.push(`<rect x="${table.x + 20}" y="${table.y + 16}" width="19" height="19" rx="3" fill="none" stroke="${headerAccent}" stroke-width="2"/>`);
  output.push(`<path d="M ${table.x + 22} ${table.y + 22} H ${table.x + 37} M ${table.x + 22} ${table.y + 28} H ${table.x + 37}" stroke="${headerAccent}" stroke-width="2"/>`);
  output.push(`<text x="${table.x + 50}" y="${table.y + 33}" class="table-name">${escapeXml(table.name)}</text>`);
  output.push(`<line x1="${table.x}" y1="${table.y + CARD.headerHeight}" x2="${table.x + table.width}" y2="${table.y + CARD.headerHeight}" stroke="${borderColor}" stroke-width="1.5"/>`);

  table.columns.forEach((column, index) => {
    const rowTop = table.y + CARD.headerHeight + index * CARD.rowHeight;
    const rowTextY = rowTop + 20;
    if (index % 2 === 1) {
      output.push(`<rect x="${table.x + 2}" y="${rowTop}" width="${table.width - 4}" height="${CARD.rowHeight}" fill="#f8fbfd"/>`);
    }
    output.push(renderBadge(table.x + 13, rowTop + 6, column));
    output.push(`<text x="${table.x + 72}" y="${rowTextY}" class="${column.notNull ? "column-required" : "column"}">${escapeXml(column.name)}</text>`);
    output.push(`<text x="${table.x + table.width - 14}" y="${rowTextY}" class="type" text-anchor="end">${escapeXml(column.type)}</text>`);
    if (index < table.columns.length - 1) {
      output.push(`<line x1="${table.x + 2}" y1="${rowTop + CARD.rowHeight}" x2="${table.x + table.width - 2}" y2="${rowTop + CARD.rowHeight}" stroke="#e7eef4"/>`);
    }
  });

  output.push(`</g>`);
  return output.join("");
}

function renderBadge(x, y, column) {
  let label = "";
  let color = "#94a3b8";
  let width = 42;
  if (column.primaryKey && column.foreignKey) {
    label = "PK·FK";
    color = "#d97706";
    width = 52;
  } else if (column.primaryKey) {
    label = "PK";
    color = "#f59e0b";
  } else if (column.foreignKey) {
    label = "FK";
    color = "#0284c7";
  } else if (column.unique) {
    label = "UQ";
    color = "#7c3aed";
  } else {
    return `<circle cx="${x + 18}" cy="${y + 8}" r="3" fill="#a8bac8"/>`;
  }

  return `<g><rect x="${x}" y="${y - 1}" width="${width}" height="19" rx="5" fill="${color}"/>` +
    `<text x="${x + width / 2}" y="${y + 13}" class="badge" text-anchor="middle">${escapeXml(label)}</text></g>`;
}

function escapeXml(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&apos;");
}

function toPortablePath(value) {
  return value.replaceAll("\\", "/");
}

function main() {
  const options = parseArguments(process.argv.slice(2));
  const inputPath = path.resolve(options.input);
  const outputPath = path.resolve(options.output);
  const sql = fs.readFileSync(inputPath, "utf8");
  const model = parseSchema(sql);
  validateModel(model);
  enrichLayout(model);

  const svg = renderSvg(model, path.relative(process.cwd(), inputPath));
  fs.mkdirSync(path.dirname(outputPath), { recursive: true });
  fs.writeFileSync(outputPath, svg, "utf8");

  const nullableForeignKeyColumns = new Set();
  for (const foreignKey of model.foreignKeys) {
    const child = requireTable(model, foreignKey.childTable);
    for (const columnName of foreignKey.childColumns) {
      if (!requireColumn(child, columnName).notNull) {
        nullableForeignKeyColumns.add(`${child.name}.${columnName}`);
      }
    }
  }

  console.log(JSON.stringify({
    output: outputPath,
    width: CANVAS.width,
    height: CANVAS.height,
    tables: model.tables.size,
    foreignKeys: model.foreignKeys.length,
    nullableForeignKeyColumns: nullableForeignKeyColumns.size,
  }, null, 2));
}

try {
  main();
} catch (error) {
  console.error(error instanceof Error ? error.stack : error);
  process.exitCode = 1;
}
