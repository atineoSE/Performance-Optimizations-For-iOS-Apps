# Performance optimizations for iOS apps

This is the companion code to [my talk at the Telecommunications School at the University of Málaga on performance optimizations for iOS apps last 21/01/2021](https://www.uma.es/etsi-de-telecomunicacion/noticias/conferencia-optimizacion-de-apps-ios-consideraciones-basicas-y-casos-practicos/).

## Sample app

Let us explore some basic performance optimizations that we can apply in a common scenario for iOS apps. Feel free to follow the code step by step with every commit. 

Our sample app is **FilmMakers**:  a concept for an app displaying information about movie directors and actors. We are focused on the profile screen, loaded with sample data from Quentin Tarantino.

![capture_with_skin](./capture_with_skin.png)

## Initial state

[Commit](https://github.com/atineoSE/Performance-Optimization-For-iOS-Apps/commit/72aa26f3072574485f957c01b0e35ab665de1052) 

We start by loading all poster images from the network and initializing our data source once all data is locally available. We perform GET requests on image URLs, hardcoded for the example (they would typically come from a previous query to a RESTful API in a complete app).

This is the performance baseline we will take as starting point. For clearer results, you may want to use a [Link Conditioner](https://download.developer.apple.com/Developer_Tools/Additional_Tools_for_Xcode_11/Additional_Tools_for_Xcode_11.dmg), to simulate slow network connections. 

## Measure

[Commit](https://github.com/atineoSE/Performance-Optimization-For-iOS-Apps/commit/0ac10c01e566eb8e66b1ffbef11b24e98d88cead)

Don't optimize based on hunches and assumptions. Instead, measure. Find where the bottleneck is and use a stopwatch to check your progress.

Here we add a simple UI performance test to measure the time it takes to come on the screen and be ready for user interaction. 

## Defer

[Commit](https://github.com/atineoSE/Performance-Optimization-For-iOS-Apps/commit/72ee63fce059eb9e7403037f1f6143721d951525)

One of the most important techniques we can apply in performance optimization is **defer**. In other words, take expensive operations outside the critical path. 

In this case, we want to present content and be ready for user input as fast as we can, while deferring expensive operations to a later moment.

To this end, we leverage available collection view cell lifecycle methods, and we save the expensive image load for the `collectionView(_:willDisplay:forItemAt:)` method, when we know the cell is actually going to be shown to the user.

Like that, we avoid fetching images that might not be shown to the user: the user might not scroll all the way to the end of the list, so fetching those images would be unnecessary. 

## Fix UI performance test

[Commit](https://github.com/atineoSE/Performance-Optimization-For-iOS-Apps/commit/0a87c382a126fc72b7b922f49a7a058cc9339ff1)

We have broken our test now, since we are facing now a new delay when presenting the poster in the detail view. We have to adapt the test to wait for the image to be available. 

Often, changing code means that we also need to change the tests and this is no different for performance tests. It's also important to know what we are measuring and not to cheat. We want to measure the time it takes for the first poster to be available for the user, so we adapt the test accordingly.

By measuring again, we should notice a faster time to present the initial content to the user, since we are now saving extra loads for images that are not initially displayed.

## Memoization

[Commit](https://github.com/atineoSE/Performance-Optimization-For-iOS-Apps/commit/38015f4c9d6988b299c0e9759dce7389e941bd1b)

Another classic performance optimization technique is to prevent expensive operations by storing previously obtained results, so that we don't have to pay the cost multiple times. Of course, this has tradeoffs in memory used.

In this case, we can greatly improve the experience by storing the fetched image so that we don't have to keep fetching them every time we scroll the list of posters back and forth.

Our UI performance test does not reveal any improvement because we are now improving in another dimension: not in the first load, but in the subsequent loads. Here, a manual test works best to feel the improvement in the user experience.

Note: for the sake of clarity, we are using an ephemeral URLSession here, so as to prevent network caching, which happens transparently for us, possibly obscuring the fact that we might be actually architecting in a way that relies too much on fetching from the network.

## Hide latency with animation

[Commit](https://github.com/atineoSE/Performance-Optimization-For-iOS-Apps/commit/e6ed074e8bcfe99d35f49ed24387323a0887024a)

One particular aspect of performance optimization in user interfaces is that what really matters is not the actual, raw performance, but the *perceived* performance. 

It turns out we can give the impression that we are performing better than we actually are, by using animations to bridge waiting times.

Here we are going to introduce a fading animation from the placeholder poster to the actual image, when it becomes available. Whereas before we had a "jump" when the image is loaded, here we are blending the image almost inadvertedly. 

This is again not something we measure in raw seconds but in the actual feel through manual testing. It is a subtle but noticeable improvement. 

## Integrate with your environment

[Commit](https://github.com/atineoSE/Performance-Optimization-For-iOS-Apps/commit/6d94f18649ed60be844257e0b76b4848abd9bd7c)

Not all optimizations are obtained through sophisticated techniques. Some are just a result of using the right data in the right context, which requires integrating closely with other services.

In this case, we realize that the server actually offers low- and high-res images for the posters, so it's only natural that we use the low-res ones for the list view and the high-res ones for the poster detail. This is typical of CDN services, that tend to offer a range of sizes for consumption by different use cases.

Note that we start wit the low-res image in the poster detail and fade into the high-res image as soon as it becomes available. Again the animation works to hide latency and only the keenest eyes would notice that the image in the poster detail started less sharp that it actually ends up being.

Also notice that this only happens on the first fetch, since we are locally storying the image for immediate reuse for subsequent uses.

Our performance test will run now a bit faster, since we fetch smaller images. It could be argued that we are cheating a bit, since we time until presenting the first poster from the low-res image already, but as we saw, the change into the high-res one is almost seamless so we don't count that into the actual cost of loading the first poster.

## Use prefetching to hide latency

[Commit](https://github.com/atineoSE/Performance-Optimization-For-iOS-Apps/commit/f4720444ecd6b034ec3756f335be747e8b0d3f47)

A classic latency-hiding technique is to prefetch content speculatively. This is based on predicting user behaviour. Choosing when to prefetch can be quite nuanced and here it's better to rely on the system's built-in prefetching mechanism by conforming to the `UICollectionViewDataSourcePrefetching` protocol and letting the system decide when to prefetch and when to cancel a prefetch, based on the user scrolling of the list of posters.

If the user is not scrolling too fast, the effect is that the newly revealed cell are already there when we display them, as we are prefetching them in advance to them being actually displayed. We only face some delay upon the initial load and if the user starts scrolling very fast. 

Our performance test won't show any change this time, since we are again working on content loaded as it is revealed during the scrolling, something which is better felt in a manual test.

Note that our code now is becoming more complex, since we need to deal with several simultaneous requests that could be cancelled, and that could be performed either in the normal cell lifecycle or in the prefetching operation.

Is this added complexity worthwhile, when we use it only for the initial fetch of an image? It depends on the actual project constraints. Software development is the art of tradeoffs and pros and cons must be carefully considered.

## More animation for latency hiding

[Commit](https://github.com/atineoSE/Performance-Optimization-For-iOS-Apps/commit/ba6d6b3ba0cd48de8ae464469b6058ff0b0fe1e1)

We have gone now a long way to improve the user experience for this screen, with optimizations for coming into view as fast as possible, and also for improving the experience of revealing more content progressively. The only bit that still feels like a drag is the load of the initial posters in the list.

We could apply again the latency-hiding technique by adding an animation to slide the content from below with a slight bounce, while dropping the profile image from the top. The loading animation of the images now blends with these initial animations, almost giving the impression that the progressive disclosure of content is part of the design.

I don't necessarily recommend applying this change, since such a bold animation has to blend in with the app character and should to be consistent across the app. However, if the app's mood is dynamic and snappy, then it could fit in quite nicely and further reduce perceived waiting times.







