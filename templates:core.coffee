
# Core for `templates` packages.
@TemplatesPackage = (name, org) ->
  this.namespace = "#{org || 'templates'}:#{name}"

# Add custom namespaced methods to Blaze.TemplateInstance.prototype.
@TemplatesPackage.prototype.methods = (methods) ->
  for name, method of methods
    Blaze.TemplateInstance.prototype["#{this.namespace}:#{name}"] = method

# Add namespaced properties to unique template instance
@TemplatesPackage.prototype.extend = (instance, props) ->
  for name, value of props
    instance["#{this.namespace}:#{name}"] = value

# Provide a way to turn namespace strings into real items, preserving context
Registry = ->
  # Empty object

Registry.prototype.into = (context) ->
  items = {}
  for own name, translation of this
    item = context[translation]
    items[name] = Match.test(item, Function) && _.bind(item, context) || item
  return items

# Get fully namespaced method or property name(s)
@TemplatesPackage.prototype.translate = (names...) ->
  obj = new Registry
  for name in names
    obj[name] = "#{this.namespace}:#{name}"
  return obj

# Get namespaced method or property without registry
@TemplatesPackage.prototype.lookup = (name) ->
  return "#{this.namespace}:#{name}"