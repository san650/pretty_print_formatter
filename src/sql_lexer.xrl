%% https://github.com/basho/riak_ql/blob/359f2979d75d374b4ba7d0f9ac5a39149a9c2af4/priv/keyword_generator.rb
Definitions.

KEYWORDS   = (AND|ANY|AS|ASC|BY|CONFLICT|DELETE|DESC|DISTINCT|DO|FALSE|FROM|GROUP|INNER|INSERT|INTO|IS|JOIN|LEFT|LIMIT|NULL|ON|OR|ORDER|OUTER|RECURSIVE|RETURNING|SELECT|SET|TRUE|UPDATE|VALUES|WITH|WHERE)
INT        = [0-9]+
NAME       = [a-z0-9"_.]+
WHITESPACE = [\s\t\n\r]
SEPARATOR  = ,
OPERATORS  = [*+=<>!]+
%% STRING     = ".*"
VARIABLE   = \$[0-9]+

Rules.

{KEYWORDS}    : {token, {keyword, TokenLine, TokenChars}}.
{INT}         : {token, {integer, TokenLine, TokenChars}}.
{NAME}        : {token, {name, TokenLine, TokenChars}}.
\(            : {token, {paren_open, TokenLine}}.
\)            : {token, {paren_close, TokenLine}}.
{WHITESPACE}+ : skip_token.
{SEPARATOR}   : {token, {separator, TokenLine}}.
{OPERATORS}   : {token, {operator, TokenLine, TokenChars}}.
%% {STRING}      : {token, {string, TokenLine, TokenChars}}.
{VARIABLE}    : {token, {variable, TokenLine, TokenChars}}.

Erlang code.
