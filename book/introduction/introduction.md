# Introduction

## Why this book?

There are many ways to build the backend for a React Native application, but you
only need one. The solution you choose depends on the complexity of the API you
will create.

Rails is fantastic for creating web applications and basic APIs in minutes. But,
deciding how to structure your API can be challenging. It is always fun to play
with a project, but sometimes, you want to get going. This book will help you do
that. Your API will need some tweaking while you flesh out your React Native
app. We will define and build the API first and then consume this API through
our React Native app.

The Rails portions of this book will guide you through our preferred way of
building a JSON API with Rails. We provide code samples for GET, POST, and PATCH
requests. We will also explore some of the other approaches we didn't choose and
explain why we made the choices we did.

The React Native part of the book then walks you through creating a React Native
app that consumes your new API. The application will use each endpoint to post
up objects and get back necessary data for the user. We will populate the
objects in our React Native app with response data from the API. These objects
will correspond with those in our Rails database.

## Who is this book for?

This book is for a developer who wants to build a React Native application with
a Rails backend. It's also a book for both a Rails developer and a React Native
developer to share and use in concert. The content will permit them to create a
flexible app fast.

This book's approach results from our experiments as Rails and React Native
developers. We assume a basic knowledge of how to build a web application with
Rails and familiarity with Ruby. We also expect you to have experience with the
JavaScript programming language.

We intend you to use this book as a guide rather than a recipe. We aim to give
you all the tools necessary to build great Rails APIs and React Native clients.
But this book excludes the fundamentals of Ruby, Rails, or JavaScript. If any
part of the book strikes you as incomplete or confusing, please submit a pull
request or issue on [GitHub][].

[github]: https://github.com/thoughtbot/ios-on-rails
