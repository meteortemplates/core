About
-----

Standard core for packages in the `templates` organization.

This package provides the following benefits:

1. Optimizes performance by putting package methods on `Blaze.TemplateInstance.prototype`.
2. Optimizes safety by namespacing methods and properties by `organization:package`.
3. Establishes an API that encourages scalable code and best practices.

Install
-------

`meteor add templates:core`

It's usually not necessary to install this package. It's included and used invisibly by
some of the `templates` packages.

Usage
-----

Initialize a new package under a unique namespace. Here we'll build a basic **like button**.

Assume all the following code is being run on the **client-side only**.

```javascript
Likes = new TemplatesPackage('likes');
```

Add safely namespaced methods available on `Template` instances through the prototype.

```javascript
Likes.methods({
  increaseLikes: function () {
    // Get properties from namespace without having to type the namespace
    var self = Likes.translate('collection', 'docId', 'incop').into(this);
    self.collection.update({_id: self.docId}, self.incop);
  }
})
```

Add safely namespaced properties onto every `Template` instance.

```javascript
Template.likeButton.created = function () {
  var props = {}
    , inc = {};

  // An instance of Mongo.Collection from a helper.
  props.collection = this.data.collection;

  // The document to modify (from inside an `{{#each}}` block).
  props.docId = Template.parentData(1)._id;

  // The key where the like count is stored.
  props.key = this.data.key || 'likes';

  // The database operation that increases the like count.
  inc[props.key] = 1;
  props.incop = {$inc: inc};

  // Ok, so we have all these in an object--
  // We haven't polluted the Template Instance's root namespace.

  // Let's put them on the instance in a safe namespace (`templates:likes` here).
  Likes.extend(this, props);

};
```

Add helpers and events for the `Template` we're working with that make it easy to work
with our custom namespace.

```javascript
// Let's create a helper to get the current doc's like count.
Template.likeButton.helpers({
  likeCount: function () {
    var instance = Template.instance();
    var self = Package.translate('key').into(instance); // Returns `templates:likes:key`.
    return Template.parentData(1)[self.key];
  }
});

// Now let's add the event handler that increments the like count by clicking a button.
// It uses our namespaced prototype method, so we don't duplicate the method every time
// a new `Template.likeButton` is rendered.
Template.likeButton.events({
  'click .like-button': function (event, instance) {

    // We use `lookup` for prototype methods because it skips using an internal registry that
    // would otherwise run `_.bind` on functions. It returns the namespaced method name.

    var method = Package.lookup('increaseLikes'); // Returns `templates:likes:increaseLikes`.
    instance[method]();
  }
})
```

Finally, test the functionality out in the wild.

```javascript
Animals = new Mongo.Collection('animals', null);

// Seed some wild animals.
Meteor.startup(function () {
  if (Animals.find().count() === 0) {
    Animals.insert({
      name: 'Wild Lion',
      likes: 0
    });

    Animals.insert({
      name: 'Wild Panther',
      likes: 0
    });

    Animals.insert({
      name: 'Wild Human',
      likes: 0
    });
  }
});

// Add helpers for our test template.
Template.testLikes.helpers({
  collection: function () {
    return Animals;
  },
  animals: function () {
    return Animals.find();
  }
});

```

```handlebars
<head>
  <title>Wild Animals Are Crazy. And They Need Likes.</title>
</head>

<body>
  {{> testLikes}}
</body>

<template name="testLikes">
  <h2>ANIMALS</h2>
  {{#each animals}}
    {{name}} {{> likeButton collection=collection}}<br>
  {{/each}}
</template>

<template name="likeButton">
  <button class="like-button">ADD A LIKE!</button>
  Likes: {{likeCount}}
</template>
```

And there we go--a well-written, safe package.

> Note: Don't actually use this example for anything serious.
> It's an over-simplified take on a package I'm working on currently.


API
---

`TemplatesPackage.methods(/* object */)`

* Takes an object of non-namespaced methods.
* Converts them into namespaced methods on `Blaze.TemplateInstance.prototype`.
* Prevents creating lots of duplicated functions, especially when large lists of items are rendered.

`TemplatesPackage.extend(/* instance */, /* object */)`

* Takes a template instance object and an object of non-namespaced properties.
* Converts the properties into namespaced properties and adds them to the instance.
* Meant to be used inside `Template.created` or `Template.rendered`.

`TemplatesPackage.translate(/* strings */)`

* Takes a variable-length list of strings for non-namespaced properties and/or methods.
* Returns an instance of `Registry`:
  * An object with non-namespaced names as keys, and namespaced names as values.
    * For example, `{'incop': 'templates:likes:incop'}`.
  * Registry objects have a prototype method `Registry.into(/* context */)`.
    * This method returns an object with the real values, using a given context.
    * Don't use this for prototype methods, as it returns bound methods.

`TemplatesPackage.lookup(/* string */)`

* Takes a single non-namespaced property or method name.
* Returns the corresponding namespaced property or method name.
* Use the returned string inside bracket notation on a template instance to get the value.
  * This is the recommended way to work with methods.


Contributors
------------

* [Jon James](http://github.com/jonjamz)

My goal with this package is to keep it simple and flexible, as a minimal foundation for other packages.

I hope to rarely change the API, but am always open to ideas for improvements.

**Please create issues to discuss feature contributions before creating a pull request.**

