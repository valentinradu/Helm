<p align="center">
  <img src="helm.svg" />
</p>

<div align="center">

[![SwiftUI](https://img.shields.io/badge/SwiftUI-blue.svg?style=for-the-badge&logo=swift&logoColor=black)](https://developer.apple.com/xcode/swiftui)
[![Swift](https://img.shields.io/badge/Swift-5.3-orange.svg?style=for-the-badge&logo=swift)](https://swift.org)
[![Xcode](https://img.shields.io/badge/Xcode-13-blue.svg?style=for-the-badge&logo=Xcode&logoColor=white)](https://developer.apple.com/xcode)
[![MIT](https://img.shields.io/badge/license-MIT-black.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

</div>

Helm is a declarative, graph-based navigation library for SwiftUI. It's like a router on steroids that fully describes all the navigation flows in an app and can handle complex overlapping UI, modals, deeplinking and much more.

## Index
* [Overview](#overview)
* [Error handling](#error-handling)
* [Deeplinking](#deeplinking)
* [Snapshot testing](#snapshot-testing)
* [Examples](#example)
* [License](#license)

## Overview

Helm has a declarative approach, which means you have to first construct the underlying navigation graph with its nodes, edges and rules, and only then, you can harness its power in SwiftUI.

### Define the navigation graph

First we have define all the possible dynamic sections of the app: some might be full screens, others, just overlapping views, like a player in a music listening app. This is usually done in an `enum` conforming to the `Node` protocol. This step is done as soon as the app starts and the resulting graph is not mutable (although you can mutate the traits as we will see later).

```swift
enum Sections: Node {
    // the first screen right after the app starts
    case splash

    // the screen that contains the login, register or forgot password sections
    case gatekeeper
    // the three sections of the gatekeeper screen
    case login
    case register
    case forgotPass
    
    // once the user is logged in, the dashboard is available
    case dashboard
    // which has 2 sections
    case news
    case library
    
    // also, let's say that you can write new articles once you can access the dashboard
    case compose
    
    // and so on ...
}
```

Conceptually, we now have:

<p align="center">
  <img src="flow-no-segues.svg" />
</p>

Just a bunch of sections in our app, but with no navigation rules. In Helm, navigation rules are defined using segues and segues traits. Segues define the edges that connect the app sections and their direction, while traits add extra constraints for using relative navigation (it helps Helm understand what do we mean by `dismiss()` or `forward()`) and for disabling, redirecting or presenting overlapping nodes (more about this a bit later).

We have to first define the segues. For that, we will use a `Flow` which is just an ordered collection of unique segues. Normally, we'd need to create and add each segue manually:

```swift
// don't do this, use segue operators
let flow = Flow<Sections>(segue: Segue(.splash, to: .gatekeeper))
    .add(segue: Segue(.splash, to: .dashboard))
    .add(segue: Segue(.gatekeeper, to: .login))
    .add(segue: Segue(.gatekeeper, to: .register))
    // and so on ...
```

This is extra verbose, so, instead, we can use the segue operators `=>` and `<=>`. `.splash => .gatekeeper` creates a directional segue between the two nodes, while `<=>` creates two segues (a bidirectional connection), `.login <=> .register <=> .forgotPass <=> .login`, which translates to: from each of the mentioned nodes you can visit the others.

The segue operators also support arrays, creating one to many segues (`.gatekeeper => [.login, .register, .forgotPass]`) or many to one segues (`[.login, .register] => .dashboard`). Segues operators don't support many-to-many connections.

Using the operators, the full flow definition becomes:

```swift
// depending on whether the user is logged in or not, 
// you can navigate from the .splash screen to the .gatekeeper or directly to the .dashboard
let flow = Flow<Sections>(segue: .splash => [.gatekeeper, .dashboard])
    // the gatekeeper contains three sub-sections
    .add(segue: .gatekeeper => .login)
    // from each of the gatekeeper sub-section you can navigate to the others
    .add(segue: .login <=> .register <=> .forgotPass <=> .login)
    // both from .login and .register you can reach the dashboard
    // if the login or the register operation succeeds  
    .add(segue: [.login, .register] => .dashboard)
    // once in the dashboard, we can visit either the .news or the .library section
    .add(segue: .dashboard => [.news, .library]) 
    // also, you can go to the article section and back
    .add(segue: .dashboard <=> .compose)
```

We defined our navigation almost entirely. This corresponds to:

<p align="center">
  <img src="flow-with-segues.svg" />
</p>

Lastly, we create the navigation graph and add the segues traits.
First, since both `.gatekeeper` and `.dashboard` are container nodes and can't be presented by themselves, we shall automatically forward all navigation that passes through them to `.login` and `.news` respectively using the `.auto` segue trait.
Second, we need to let Helm know that `.compose` is a modal and that its siblings, `.library` and `.news` should not be deactivated when presenting it. We'll use the `.modal` segue trait to do so.
Third, since the user starts unauthenticated, we redirect all attempts to reach the `.dashboard` from the `.splash` to the `.gatekeeper` using the `.redirect(to:)` segue trait. This should change once the user becomes authenticated.

```swift
let graph = NavigationGraph(flow: flow)
// we add the `.auto` trait
graph.edit(segue: .gatekeeper => .login)
    .add(trait: .auto)
graph.edit(segue: .dashboard => .news)
    .add(trait: .auto)
// we mark .compose as a modal
graph.edit(segue: .dashboard => .compose)
    .add(trait: .modal)
// and redirect access to the .dashboard from .splash to the .gatekeeper
graph.edit(segue: .splash => .dashboard)
    .add(trait: .redirect(to: Flow(segue: .splash => .gatekeeper)))
```

Resulting our final navigation graph.

<p align="center">
  <img src="flow-with-segues-and-traits.svg" />
</p>
