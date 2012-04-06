define('ace/mode/solid_highlight_rules', function(require, exports, module) {

var oop = require("../lib/oop");
var HtmlHighlightRules = require("ace/mode/html_highlight_rules").HtmlHighlightRules;
var TextHighlightRules = require("ace/mode/text_highlight_rules").TextHighlightRules;

var TextHighlightRules = require("./text_highlight_rules").TextHighlightRules;
var lang = require("../lib/lang");

var SolidVariableHighlightRules = function() {
    this.$rules = {
      "start" : [
          {
             token : "variable.context",
             regex : "[a-z_][a-zA-Z0-9_$]*\\b",
             next  : 'filter'
          }, {
             token : "constant.language",
             regex : "[a-zA-Z_][a-zA-Z0-9_$]*\\b",
             next  : 'filter'
          }, {
             token : "string", // single line
             regex : '["](?:(?:\\\\.)|(?:[^"\\\\]))*?["]'
          }, {
             token : "string", // single line
             regex : "['](?:(?:\\\\.)|(?:[^'\\\\]))*?[']"
         }, {
             token : "string", // backtick string
             regex : "[`](?:(?:\\\\.)|(?:[^'\\\\]))*?[`]"
         }
      ],
      'filter' : [
          {
            token : "keyword.operator",
            regex : "\\|",
            next  : 'filter'
          }, {
              token : "keyword.operator",
              regex : "\:"
          }, {
            token : "support.function",
            regex : "[a-zA-Z_$][a-zA-Z0-9_$]*\\b"
          }, {
            token : "string", // single line
            regex : '["](?:(?:\\\\.)|(?:[^"\\\\]))*?["]'
          }, {
            token : "string", // single line
            regex : "['](?:(?:\\\\.)|(?:[^'\\\\]))*?[']"
          }, {
            token : "string", // backtick string
            regex : "[`](?:(?:\\\\.)|(?:[^'\\\\]))*?[`]"
          } 
      ]
    };
};

oop.inherits(SolidVariableHighlightRules, TextHighlightRules);

exports.SolidVariableHighlightRules = SolidVariableHighlightRules;


var SolidTagHighlightRules = function() {

    var builtinConstants = lang.arrayToMap(
        ("true|false|nil").split("|")
    );
    this.$rules = {
        "start" : [
            {
               token : "support.function",
               regex : "[a-zA-Z_$][a-zA-Z0-9_$]*\\b",
               next  : "literals"
            }
        ],
        "literals" : [
            {
                token : "string.regexp",
                regex : "[/](?:(?:\\[(?:\\\\]|[^\\]])+\\])|(?:\\\\/|[^\\]/]))*[/]\\w*\\s*(?=[).,;]|$)"
            }, {
                token : "string", // single line
                regex : '["](?:(?:\\\\.)|(?:[^"\\\\]))*?["]'
            }, {
                token : "string", // single line
                regex : "['](?:(?:\\\\.)|(?:[^'\\\\]))*?[']"
            }, {
                token : "string", // backtick string
                regex : "[`](?:(?:\\\\.)|(?:[^'\\\\]))*?[`]"
            }, {
                token : "text", // namespaces aren't symbols
                regex : "::"
            }, {
                token : "constant.class", // class name
                regex : "[A-Z](?:[a-zA-Z_]|\d)+"
            }, {
                token : "constant.symbol",
                regex : "[a-zA-Z_][a-zA-Z0-9_]*\:"
            }, {
                token : "constant.symbol", // symbol
                regex : "[:](?:[A-Za-z_]|[@$](?=[a-zA-Z0-9_]))[a-zA-Z0-9_]*[!=?]?"
           }, {
                token : "constant.numeric", // hex
                regex : "0[xX][0-9a-fA-F](?:[0-9a-fA-F]|_(?=[0-9a-fA-F]))*\\b"
           },{
                token : "constant.numeric", // float
                regex : "[+-]?\\d(?:\\d|_(?=\\d))*(?:(?:\\.\\d(?:\\d|_(?=\\d))*)?(?:[eE][+-]?\\d+)?)?\\b"
           }, {
                token : "support.method",
                regex : "\\.[a-z_$][a-zA-Z0-9_$]*[\\?\\!]?\\b"
           }, {
                token : "constant.language.boolean",
                regex : "(?:true|false)\\b"
           }, {
                token : function(value) {
                    if (builtinConstants.hasOwnProperty(value))
                        return "constant.language";
                    else
                        return "variable.context";
                },
                regex : "[a-z_$][a-zA-Z0-9_$]*\\b"
           }, {
                token : "text",
                regex : "\\s+"
           }
        ]
    };
};

oop.inherits(SolidTagHighlightRules, TextHighlightRules);

exports.SolidTagHighlightRules = SolidTagHighlightRules;

var SolidHighlightRules = function() {
  // TODO: make it work for scriptembed and cssembed
  this.$rules = new HtmlHighlightRules().getRules();
  this.$rules.start.unshift({
    token: "keyword.operator",
    regex: '{%',
    next: 'solid-tag-start'
  });

  this.embedRules(SolidTagHighlightRules, "solid-tag-", [
    {
      token: ["keyword.operator", "string"],
      regex: '(%})(")',
      next: "tag_embed_attribute_list"
    }, {
      token: "keyword.operator",
      regex: '%}',
      next: "start"
    }
  ]);

  this.embedRules(SolidVariableHighlightRules, "solid-variable-", [
    {
       token: ["keyword.operator", "string"],
       regex: '(}})(")',
       next: "tag_embed_attribute_list"
    }, {
       token: "keyword.operator",
       regex: '}}',
       next: "start"
    }
  ]);

  this.$rules.start.unshift({
    token: "keyword.operator",
    regex: '{{',
    next: 'solid-variable-start'
  });

  this.$rules['tag_embed_attribute_list'].unshift({
    token: ["string", "keyword.operator"],
    regex: '(")({%)',
    next: 'solid-tag-start'
  });
  this.$rules['tag_embed_attribute_list'].unshift({
    token: ["string", "keyword.operator"],
    regex: '(")({{)',
    next: 'solid-variable-start'
  });

}

oop.inherits(SolidHighlightRules, HtmlHighlightRules);

exports.SolidHighlightRules = SolidHighlightRules;
});


define('ace/mode/solid', function(require, exports, module) {

var oop = require("../lib/oop");
var TextMode = require("ace/mode/text").Mode;
var Tokenizer = require("ace/tokenizer").Tokenizer;
var SolidHighlightRules = require("ace/mode/solid_highlight_rules").SolidHighlightRules;

var Mode = function() {
    this.$tokenizer = new Tokenizer(new SolidHighlightRules().getRules());
};
oop.inherits(Mode, TextMode);

exports.Mode = Mode;
});
