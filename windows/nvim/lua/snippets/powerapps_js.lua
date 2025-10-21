
-- lua/snippets/powerapps_js.lua
-- Power Apps (Model-Driven) JavaScript snippets for LuaSnip
-- Preview shows the cheat-sheet comments; expansion inserts clean code.

local ls = require("luasnip")
local s  = ls.snippet
local t  = ls.text_node
local i  = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

-- Helper to make long preview descriptions easier to read
local function lines(txt) return txt end

-- Filetypes these snippets apply to
local ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" }

ls.add_snippets(ft, {

  -- FORM: OnLoad handler
  s(
    { trig = "mdonload", name = "Form OnLoad", dscr = lines([[
Runs on the form OnLoad event.
Signature: function (executionContext) { var formContext = executionContext.getFormContext(); }
Usage: Register Sdk.formOnLoad in the form library and pass executionContext.
]]) },
    fmt([[
var Sdk = window.Sdk || {};
(function () {{
  this.formOnLoad = function (executionContext) {{
    var formContext = executionContext.getFormContext();
    {}
  }};
}}).call(Sdk);
]], { i(0, "// code") })
  ),

  -- FORM: OnSave handler
  s(
    { trig = "mdonsave", name = "Form OnSave", dscr = lines([[
Runs on the form OnSave event.
Signature: function (executionContext) { var formContext = executionContext.getFormContext(); }
]]) },
    fmt([[
var Sdk = window.Sdk || {};
(function () {{
  this.formOnSave = function (executionContext) {{
    var formContext = executionContext.getFormContext();
    {}
  }};
}}).call(Sdk);
]], { i(0, "// code") })
  ),

  -- ATTRIBUTE: OnChange handler
  s(
    { trig = "mdonchange", name = "Column OnChange", dscr = lines([[
Runs on a column's OnChange event.
Get formContext via the executionContext argument and read/update attributes.
]]) },
    fmt([[
var Sdk = window.Sdk || {};
(function () {{
  this.attributeOnChange = function (executionContext) {{
    var formContext = executionContext.getFormContext();
    {}
  }};
}}).call(Sdk);
]], { i(0, "// code") })
  ),

  -- CURRENT ROW DATA
  s(
    { trig = "mdrow", name = "Get current row (entity, id, name)", dscr = lines([[
Get current row reference:
entityType → logical name; id → GUID (with/without braces); name → primary name.
]]) },
    fmt([[
var current = formContext.data.entity.getEntityReference();
var currentEntity = current.entityType;
var currentId = current.id;
var currentIdNoBraces = current.id.replace(/{{|}}/g, "");
var currentName = current.name;
{}
]], { i(0) })
  ),

  -- LOOKUP READ + SET
  s(
    { trig = "mdlookup", name = "Read/Set lookup value", dscr = lines([[
Read lookup: getValue() returns array [{ id, entityType, name }].
Set lookup: setValue([{ id, entityType, name }]).
]]) },
    fmt([[
var val = formContext.getAttribute("{}").getValue();
if (val) {{
  var entityType = val[0].entityType;
  var id = val[0].id;
  var name = val[0].name;
}}
var setVal = [{{ id: "{}", entityType: "{}", name: "{}" }}];
formContext.getAttribute("{}").setValue(setVal);
{}
]], { i(1, "customerid"), i(2, "00000000-0000-0000-0000-000000000000"), i(3, "contact"), i(4, "Nancy Anderson (sample)"), i(5, "customerid"), i(0) })
  ),

  -- SHOW / HIDE FIELD
  s(
    { trig = "mdshow", name = "Show/Hide field", dscr = lines([[
Use getControl(...).setVisible(true|false) to show or hide.
]]) },
    fmt([[
formContext.getControl("{}").setVisible({});
{}
]], { i(1, "caseorigincode"), i(2, "true"), i(0) })
  ),

  -- REQUIRED LEVEL
  s(
    { trig = "mdreq", name = "Set required level", dscr = lines([[
required|recommended|none via setRequiredLevel.
]]) },
    fmt([[
formContext.getAttribute("{}").setRequiredLevel("{}");
{}
]], { i(1, "fieldname"), i(2, "required"), i(0) })
  ),

  -- READ COLUMN VALUES
  s(
    { trig = "mdget", name = "Get value / choice / text", dscr = lines([[
getValue() for value/choice; getText() for choice text.
]]) },
    fmt([[
var v = formContext.getAttribute("{}").getValue();
var t = formContext.getAttribute("{}").getText();
{}
]], { i(1, "fieldname"), i(2, "fieldname"), i(0) })
  ),

  -- WEB API: RETRIEVE
  s(
    { trig = "mdgetapi", name = "Xrm.WebApi.retrieveRecord", dscr = lines([[
Basic retrieve and with $expand for related data. Promise resolves with result object.
]]) },
    fmt([[
Xrm.WebApi.retrieveRecord("{}", "{}", "{}").then(
  function (result) {{
    {}
  }},
  function (error) {{
    console.log(error.message);
  }}
);
]], { i(1, "contact"), i(2, "GUID_HERE"), i(3, "?$select=firstname"), i(0, "console.log('Firstname:', result.firstname);") })
  ),

  -- DIALOGS
  s(
    { trig = "mddialog", name = "Alert / Confirm dialogs", dscr = lines([[
Xrm.Navigation.openAlertDialog / openConfirmDialog.
]]) },
    fmt([[
var alertStrings = {{ confirmButtonLabel: "OK", text: "{}", title: "{}" }};
var alertOptions = {{ height: 120, width: 260 }};
Xrm.Navigation.openAlertDialog(alertStrings, alertOptions);

var confirmStrings = {{ text: "{}", title: "{}" }};
var confirmOptions = {{ height: 200, width: 450 }};
Xrm.Navigation.openConfirmDialog(confirmStrings, confirmOptions).then(function (res) {{
  if (res.confirmed) {{ {} }}
}});
]], { i(1, "This is an alert."), i(2, "Sample title"), i(3, "Proceed?"), i(4, "Confirmation"), i(5, "console.log('OK');") })
  ),

  -- DISABLE WHOLE TAB
  s(
    { trig = "mddisabtab", name = "Disable all fields in tab", dscr = lines([[
Iterate controls in every section of a tab and disable them.
]]) },
    fmt([[
(function () {{
  var tab = formContext.ui.tabs.get("{}");
  tab.sections.forEach(function (section) {{
    section.controls.forEach(function (ctrl) {{ ctrl.setDisabled(true); }});
  }});
}})();
{}
]], { i(1, "Summary"), i(0) })
  ),

  -- DISABLE SECTION
  s(
    { trig = "mddisabsec", name = "Disable all fields in section", dscr = lines([[
Disable all controls inside a specific section in a tab.
]]) },
    fmt([[
(function () {{
  var section = formContext.ui.tabs.get("{}").sections.get("{}");
  section.controls.get().forEach(function (ctrl) {{ ctrl.setDisabled(true); }});
}})();
{}
]], { i(1, "Summary"), i(2, "Case Details Summary"), i(0) })
  ),

  -- SHOW/HIDE TAB
  s(
    { trig = "mdtabvis", name = "Show/Hide tab", dscr = lines([[
tab.setVisible(true|false) on a named tab.
]]) },
    fmt([[
formContext.ui.tabs.get("{}").setVisible({});
{}
]], { i(1, "Details"), i(2, "true"), i(0) })
  ),

  -- REFRESH FORM
  s(
    { trig = "mdrefresh", name = "Refresh form", dscr = lines([[
formContext.data.refresh(true|false) to save+refresh or just refresh.
]]) },
    fmt([[
formContext.data.refresh({});
{}
]], { i(1, "false"), i(0) })
  ),

  -- BPF HEADER FIELD
  s(
    { trig = "mdbpf", name = "BPF (header) field ops", dscr = lines([[
Use 'header_process_' prefix for BPF header fields.
]]) },
    fmt([[
formContext.getAttribute("header_process_{}").setRequiredLevel("{}");
formContext.getControl("header_process_{}").setDisabled({});
{}
]], { i(1, "fieldname"), i(2, "required"), i(3, "fieldname"), i(4, "true"), i(0) })
  ),

  -- IFRAME SRC
  s(
    { trig = "mdiframe", name = "Set IFRAME src", dscr = lines([[
Set URL on an IFRAME control.
]]) },
    fmt([[
formContext.getControl("{}").setSrc("{}");
{}
]], { i(1, "iframe"), i(2, "https://example.com"), i(0) })
  ),
})

