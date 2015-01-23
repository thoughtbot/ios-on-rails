# Introduction

### Why this book?

There are many ways to build the backend for an iOS application but you only
need one. And depending on the complexity of the API you are going to create,
different solutions work best for different applications.

Just as Rails makes it possible to set up a basic web application in a matter of
minutes, Rails makes it possible to set up a basic API in a matter of minutes.
But deciding how to structure your API isn't easy. While experimenting with all
the options is a fun weekend project, sometimes you just want to get going.
This book will help you do just that. While your API will no doubt require some
tweaking while you flesh out your iOS app, the approach we will be taking is to
define and build the API first, and then consume this API through our iOS app.

The Rails portions of *iOS on Rails* will guide you through what we have found
to be a robust, clean, flexible way of building out a JSON API with Rails. We
provide code samples for GET, POST, and PATCH requests. In addition, we will
explore some of the alternative approaches that we didn't choose and explain
why we made the choices that we did.

The iOS portion of the book will then walk, step-by-step, through creating an
iOS application that works with the Rails API you just created. The iOS
application will use each endpoint to post up objects and get back necessary
data for the user. Our model objects in the iOS app will correspond with the
model objects in the database, and be populated with response data from the
API.

### Who is this book for?

This book is for a developer who wants to build an iOS application with a Rails
backend. It's also a book for both a Rails developer and an iOS developer to
share and use in concert. This will permit them to create an app quickly and
with more flexibility to change it than a backend-as-a-service provider like
StackMob or Parse.

The approach shared in this book is the result of our own experiments as Rails
and iOS developers working together to build an application. The Rails portions
of this book assume a basic working knowledge of how to build a web application
with Rails as well as familiarity with the Ruby programming language. The iOS
portions of this book assume experience with object oriented programming and a
basic familiarity with the Objective-C programming language.

This book is intended to be used as a guide rather than a recipe. While our aim
is to give you all the tools necessary to build great Rails APIs and iOS
clients, it does not cover the fundamentals of Ruby, Rails or Objective-C. That
being said, if any part of the book strikes you as incomplete or confusing, we
are always happy to receive pull requests and issue submissions on
[GitHub](https://github.com/thoughtbot/ios-on-rails).
