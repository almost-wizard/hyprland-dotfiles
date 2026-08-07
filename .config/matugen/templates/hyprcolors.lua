local colors = {}
<* for name, value in colors *>
colors["{{name}}"] = "rgba({{value.default.hex_stripped}}ff)"
<* endfor *>
return colors
