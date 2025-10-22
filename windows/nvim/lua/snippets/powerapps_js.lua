-- lua/snippets/powerapps_js.lua
local ls = require("luasnip")
local s, t, i = ls.snippet, ls.text_node, ls.insert_node

-- ========= FORM EVENTS (JS) =========
ls.add_snippets("javascript", {
  s("md_form_onload", {
    t({
      "// FORM EVENTS",
      "var Sdk = window.Sdk || {};",
      "(function () {",
      "  // Code to run in the form OnLoad event",
      "  this.formOnLoad = function (executionContext) {",
      "    var formContext = executionContext.getFormContext();",
      "    // Add your code from the other tables here",
      "    ",
    }),
    i(0),
    t({
      "",
      "  }",
      "",
      "  // Code to run in the column OnChange event",
      "  this.attributeOnChange = function (executionContext) {",
      "    var formContext = executionContext.getFormContext();",
      "    // Add your code from the other tables here",
      "  }",
      "",
      "  // Code to run in the form OnSave event",
      "  this.formOnSave = function (executionContext) {",
      "    var formContext = executionContext.getFormContext();",
      "    // Add your code from the other tables here",
      "  }",
      "}).call(Sdk);",
    }),
  }),

  s("md_attr_onchange", {
    t({
      "// FORM EVENTS",
      "// Code to run in the column OnChange event",
      "this.attributeOnChange = function (executionContext) {",
      "  var formContext = executionContext.getFormContext();",
      "  // Add your code from the other tables here",
      "  ",
    }),
    i(0),
    t({ "", "}" }),
  }),

  s("md_form_onsave", {
    t({
      "// FORM EVENTS",
      "// Code to run in the form OnSave event",
      "this.formOnSave = function (executionContext) {",
      "  var formContext = executionContext.getFormContext();",
      "  // Add your code from the other tables here",
      "  ",
    }),
    i(0),
    t({ "", "}" }),
  }),
})

-- ========= GET CURRENT ROW DATA / LOOKUPS =========
ls.add_snippets("javascript", {
  s("md_get_current", {
    t({
      "// GET CURRENT ROW DATA",
      "var currentRow = formContext.data.entity.getEntityReference();",
      "// Get row table type ex: “incident” or “account”",
      "var currentRowEntityType = currentRow.entityType;",
      "// Get row GUID ex: “{67e86a65-4cd6-ec11-a7b5-000d3a9c27d2}”",
      "var currentRowId = currentRow.id;",
      "// Get row GUID without brackets ex: “67e86a65-4cd6-ec11-a7b5-000d3a9c…”",
      "var currentRowIdNoBraces = currentRow.id.replace(/{|}/g, '');",
      "// Get row logical name",
      "var currentRowName = currentRow.name;",
    }),
  }),

  s("md_lookup_get", {
    t({
      "// READ VALUES FROM LOOKUP",
      'var ' }), i(1, "customer"), t(' = formContext.getAttribute("'),
    i(2, "customerid"), t({ '").getValue();',
      "// Get row table type ex: “incident” or “account”",
      "var " }), i(3, "customerEntityType"), t(" = "), i(1, "customer"), t({ "[0].entityType;",
      "// Get row GUID ex: “{67e86a65-4cd6-ec11-a7b5-000d3a9c27d2}”",
      "var " }), i(4, "customerId"), t(" = "), i(1, "customer"), t({ "[0].id;",
      "// Get row logical name",
      "var " }), i(5, "customerName"), t(" = "), i(1, "customer"), t("[0].name;"),
  }),
})

-- ========= WEB API RETRIEVE =========
ls.add_snippets("javascript", {
  s("md_retrieve", {
    t({
      "// READ VALUES FROM RELATED TABLES",
      "// Basic retrieve",
      'Xrm.WebApi.retrieveRecord("',
    }), i(1, "contact"), t('", '), i(2, "customerId"), t({ ', "?$select=' }), i(3, "firstname"),
    t({
      '").then(',
      "  function success(result) {",
      '    console.log("Retrieved values: Name: " + result.' }),
    i(3, "firstname"),
    t({
      ");",
      "    // perform operations on record retrieval",
      "  },",
      "  function (error) {",
      "    console.log(error.message);",
      "    // handle error conditions",
      "  }",
      ");",
    }),
  }),

  s("md_retrieve_expand", {
    t({
      "// READ VALUES FROM RELATED TABLES",
      "// Using expand",
      'Xrm.WebApi.retrieveRecord("',
    }), i(1, "contact"), t('", '), i(2, "customerId"),
    t({ '", "?$select=' }), i(3, "firstname"),
    t({ '&$expand=' }), i(4, "modifiedby($select=fullname;$expand=businessunitid($select=name))"),
    t({
      '").then(',
      "  function success(result) {",
      '    console.log("Name: " + result.modifiedby.fullname);',
      "    // perform operations on record retrieval",
      "  },",
      "  function (error) {",
      "    console.log(error.message);",
      "    // handle error conditions",
      "  }",
      ");",
    }),
  }),
})

-- ========= SHOW / HIDE FIELDS, SECTIONS, TABS =========
ls.add_snippets("javascript", {
  s("md_show_field", {
    t({
      "// SHOW / HIDE FIELDS",
      "// Show",
      'formContext.getControl("',
    }), i(1, "caseorigincode"), t('").setVisible(true);'),
  }),

  s("md_hide_field", {
    t({
      "// SHOW / HIDE FIELDS",
      "// Hide",
      'formContext.getControl("',
    }), i(1, "caseorigincode"), t('").setVisible(false);'),
  }),

  s("md_show_section", {
    t({
      "// SHOW / HIDE SECTIONS",
      "// Show section within a specified tab",
      'var tab = formContext.ui.tabs.get("',
    }), i(1, "Summary"),
    t('");\nvar section = tab.sections.get("'), i(2, "Timeline"),
    t('");\nsection.setVisible(true);'),
  }),

  s("md_hide_section", {
    t({
      "// SHOW / HIDE SECTIONS",
      "// Hide section within a specified tab",
      'var tab = formContext.ui.tabs.get("',
    }), i(1, "Summary"),
    t('");\nvar section = tab.sections.get("'), i(2, "Timeline"),
    t('");\nsection.setVisible(false);'),
  }),

  s("md_show_tab", {
    t({
      "// SHOW / HIDE TABS",
      "// Show tab",
      'var tab = formContext.ui.tabs.get("',
    }), i(1, "Details"),
    t('");\ntab.setVisible(true);'),
  }),

  s("md_hide_tab", {
    t({
      "// SHOW / HIDE TABS",
      "// Hide tab",
      'var tab = formContext.ui.tabs.get("',
    }), i(1, "Details"),
    t('");\ntab.setVisible(false);'),
  }),
})

-- ========= REQUIRED LEVELS / READ-ONLY / REFRESH =========
ls.add_snippets("javascript", {
  s("md_required", {
    t({
      "// SET REQUIRED FIELDS",
      "// Set field as required",
      'formContext.getAttribute("',
    }), i(1, "fieldname"), t('").setRequiredLevel("required");'),
  }),

  s("md_disable_field", {
    t({
      "// SET READ-ONLY FIELDS",
      "// Set field read-only",
      'formContext.getControl("',
    }), i(1, "caseorigincode"), t('").setDisabled(true);'),
  }),

  s("md_enable_field", {
    t({
      "// SET READ-ONLY FIELDS",
      "// Set field editable",
      'formContext.getControl("',
    }), i(1, "caseorigincode"), t('").setDisabled(false);'),
  }),

  s("md_refresh_save", {
    t({
      "// REFRESH & SAVE THE FORM",
      "// Save and refresh the form",
      "formContext.data.refresh(true);",
    }),
  }),

  s("md_refresh", {
    t({
      "// REFRESH & SAVE THE FORM",
      "// Refresh the form (without saving)",
      "formContext.data.refresh(false);",
    }),
  }),
})

-- ========= DIALOGS =========
ls.add_snippets("javascript", {
  s("md_alert", {
    t({
      "// DIALOG",
      "// alert dialog",
      'var alertStrings = { confirmButtonLabel: "Yes", text: "',
    }), i(1, "This is an alert."), t('", title: "'), i(2, "Sample title"), t({ '" };',
      "var alertOptions = { height: 120, width: 260 };",
      "Xrm.Navigation.openAlertDialog(alertStrings, alertOptions).then(",
      "  function (success) {",
      '    console.log("Alert dialog closed");',
      "  },",
      "  function (error) {",
      "    console.log(error.message);",
      "  }",
      ");",
    }),
  }),

  s("md_confirm", {
    t({
      "// DIALOG",
      "// confirm dialog",
      'var confirmStrings = { text:"',
    }), i(1, "This is a confirmation."), t('", title:"'), i(2, "Confirmation Dialog"), t({ '" };',
      "var confirmOptions = { height: 200, width: 450 };",
      "Xrm.Navigation.openConfirmDialog(confirmStrings, confirmOptions).then(",
      "  function (success) {",
      "    if (success.confirmed)",
      '      console.log("Dialog closed using OK button.");',
      "    else",
      '      console.log("Dialog closed using Cancel button or X.");',
      "  }",
      ");",
    }),
  }),
})

-- ========= SET FIELD VALUES =========
ls.add_snippets("javascript", {
  s("md_set_lookup", {
    t({
      "// SET FIELD VALUES",
      "// Set lookup value",
      "var lookupValue = [];",
      "lookupValue[0] = {};",
      'lookupValue[0].id = "',
    }), i(1, "a431636b-4cd6-ec11-a7b5-000d3a9c27d2"), t({ '";',
      'lookupValue[0].entityType = "' }),
    i(2, "contact"), t({ '";',
      'lookupValue[0].name = "' }),
    i(3, "Nancy Anderson (sample)"), t({ '";',
      'formContext.getAttribute("' }),
    i(4, "customerid"), t('").setValue(lookupValue);'),
  }),

  s("md_set_multi", {
    t({
      "// SET FIELD VALUES",
      "// Set choices values",
      'formContext.getAttribute("',
    }), i(1, "multichoice"), t('").setValue(['), i(2, "100000000,100000001,100000002"), t("]);"),
  }),

  s("md_set_text", {
    t({
      "// SET FIELD VALUES",
      "// Set text value",
      'formContext.getAttribute("',
    }), i(1, "textfield"), t('").setValue("'), i(2, "Those are the steps"), t('");'),
  }),

  s("md_set_number", {
    t({
      "// SET FIELD VALUES",
      "// Set number value",
      'formContext.getAttribute("',
    }), i(1, "numberfield"), t('").setValue('), i(2, "100"), t(");"),
  }),
})

-- ========= DISABLE ENTIRE SECTION / TAB =========
ls.add_snippets("javascript", {
  s("md_disable_section_all", {
    t({
      "// SET ALL FIELDS READ-ONLY IN SECTION",
      "this.disableSection = function(formContext, tab, section) {",
      "  var section = formContext.ui.tabs.get(tab).sections.get(section);",
      "  var controls = section.controls.get();",
      "  var controlsLenght = controls.length;",
      "  for (var i = 0; i < controlsLenght; i++) {",
      "    controls[i].setDisabled(true);",
      "  }",
      "}",
      "// call the function to disable all the fields in the section",
      'Sdk.disableSection(formContext,"',
    }), i(1, "Summary"), t('","'), i(2, "Case Details Summary"), t('");'),
  }),

  s("md_disable_tab_all", {
    t({
      "// SET ALL FIELDS READ-ONLY IN TAB",
      "this.disableTab = function(formContext, tab) {",
      "  formContext.ui.tabs.get(tab).sections.forEach(function (section){",
      "    section.controls.forEach(function (control) {",
      "      control.setDisabled(true);",
      "    })",
      "  });",
      "}",
      "// call the function to disable all the fields in the section",
      'Sdk.disableTab(formContext,"',
    }), i(1, "Summary"), t('");'),
  }),
})

-- ========= IFRAME SRC =========
ls.add_snippets("javascript", {
  s("md_iframe_src", {
    t({
      "// SET URL FOR IFRAME",
      'formContext.getControl("',
    }), i(1, "iframe"), t('").setSrc(" '), i(2, "https://danikahil.com/"), t('");'),
  }),
})

-- ========= BPF FIELDS =========
ls.add_snippets("javascript", {
  s("md_bpf_required", {
    t({
      "// FIELDS IN BPF (Business Process Flow)",
      "// Add \"header process_\" to the field name",
      "// Set field as required",
      'formContext.getAttribute("header_process_',
    }), i(1, "fieldname"), t('").setRequiredLevel("required");'),
  }),

  s("md_bpf_disable", {
    t({
      "// FIELDS IN BPF (Business Process Flow)",
      "// Add \"header process_\" to the field name",
      "// Set field read-only",
      'formContext.getControl("header_process_',
    }), i(1, "fieldname"), t('").setDisabled(true);'),
  }),
})

-- ========= HTML helpers (relative paths) =========
ls.add_snippets("html", {
  s("md_linkcss", {
    t({
      "<!-- HTML helpers: reference a stylesheet in ../styles/ -->",
      '<link rel="stylesheet" type="text/css" href="../styles/',
    }), i(1, "styles.css"), t('" />'),
  }),
  s("md_scriptjs", {
    t({
      "<!-- HTML helpers: reference a script in ../scripts/ -->",
      '<script type="text/javascript" src="../scripts/',
    }), i(1, "myScript.js"), t('"></script>'),
  }),
  s("md_imgwr", {
    t({
      "<!-- HTML helpers: reference an image in ../Images/ -->",
      '<img src="../Images/',
    }), i(1, "image1.png"), t('" />'),
  }),
})
