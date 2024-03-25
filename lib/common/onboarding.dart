// Built-in Libraries
import 'package:flutter/material.dart';

// External Libraries
import 'package:flutter_phoenix/flutter_phoenix.dart';

class Onboarding extends StatelessWidget {
  const Onboarding({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OnboardingPagePresenter(
        pages: [
          OnboardingPageModel(
            title: 'Teachers! Welcome to EduPlan',
            description: "This app was created with your needs in mind, let's learn how it works",
            imageUrl: 'assets/EduPlan_icon.png',
            bgColor: Colors.grey.shade50,
          ),
          OnboardingPageModel(
            title: 'Say hello to your lessons',
            description: "In the app, you will be met with this interface. Let's explore what all these buttons do!",
            imageUrl: 'assets/Homepage.png',
            bgColor: Colors.grey.shade50,
          ),
          OnboardingPageModel(
            title: 'Top of the homepage',
            description:
            '1. Opens profile and app settings page \n2. Download the plans of chosen week \n3. Signs-out of app \n4. Select which lesson plans to display based on selected week of the month',
            imageUrl: 'assets/Homepage_top.png',
            bgColor: Colors.grey.shade50,
          ),
          OnboardingPageModel(
            title: 'Lesson plan cards',
            description: '1. Change lesson plan description \n2. Mark lesson plan as done \n3. Change category of lesson plan',
            imageUrl: 'assets/Homepage_cards.png',
            bgColor: Colors.grey.shade50,
          ),
          OnboardingPageModel(
            title: 'Drag cards left to reveal',
            description: '1. Opens lesson plan editing menu \n2. Sends all completed lesson plans of the week to Google sheets',
            imageUrl: 'assets/Homepage_widget_dragged.png',
            bgColor: Colors.grey.shade50,
          ),
          OnboardingPageModel(
            title: 'Edit more',
            description: '1. Edit the lesson plan description \n2. Changes lesson plan category \n3. Saves changes made to the plan',
            imageUrl: 'assets/Modal_bottom_sheet.png',
            bgColor: Colors.grey.shade50,
          ),
          OnboardingPageModel(
            title: 'All set!',
            description: "Please inform your coordinator that you have made your account and wait for the coordinator to finish setting up your account",
            imageUrl: 'assets/EduPlan_icon.png',
            bgColor: Colors.grey.shade50,
          ),
        ],
      ),
    );
  }
}

class OnboardingPagePresenter extends StatefulWidget {
  final List<OnboardingPageModel> pages;

  const OnboardingPagePresenter(
      {Key? key, required this.pages})
      : super(key: key);

  @override
  State<OnboardingPagePresenter> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPagePresenter> {
  // Store the currently visible page
  int _currentPage = 0;
  // Define a controller for the pageview
  final PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        color: widget.pages[_currentPage].bgColor,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                // Pageview to render each page
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.pages.length,
                  onPageChanged: (idx) {
                    // Change current page when pageview changes
                    setState(() {
                      _currentPage = idx;
                    });
                  },
                  itemBuilder: (context, idx) {
                    final item = widget.pages[idx];
                    return Column(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Image(image: AssetImage(item.imageUrl))
                          ),
                        ),
                        Expanded(
                            flex: 1,
                            child: Column(children: [
                              Padding(
                                padding: const EdgeInsets.all(0),
                                child: Text(item.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6
                                        ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: item.textColor,
                                    )),
                              ),
                              Container(
                                constraints:
                                const BoxConstraints(maxWidth: 400),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0, vertical: 8.0),
                                child: Text(item.description,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        ?.copyWith(
                                      color: Colors.black87,
                                    )),
                              )
                            ]))
                      ],
                    );
                  },
                ),
              ),

              // Current page indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.pages
                    .map((item) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: _currentPage == widget.pages.indexOf(item)
                      ? 30
                      : 8,
                  height: 8,
                  margin: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(10.0)),
                ))
                    .toList(),
              ),

              // Bottom buttons
              SizedBox(
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                        style: TextButton.styleFrom(
                            visualDensity: VisualDensity.comfortable,
                            foregroundColor: Colors.black87,
                            textStyle: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          _pageController.animateToPage(widget.pages.length - 1,
                              curve: Curves.easeInOutCubic,
                              duration: const Duration(milliseconds: 250));
                        },
                        child: const Text("Skip")),
                    TextButton(
                      style: TextButton.styleFrom(
                          visualDensity: VisualDensity.comfortable,
                          foregroundColor: Colors.black87,
                          textStyle: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        if (_currentPage == widget.pages.length - 1) {
                          Phoenix.rebirth(context);
                        } else {
                          _pageController.animateToPage(_currentPage + 1,
                              curve: Curves.easeInOutCubic,
                              duration: const Duration(milliseconds: 250));
                        }
                      },
                      child: Row(
                        children: [
                          Text(
                            _currentPage == widget.pages.length - 1
                                ? "Finish"
                                : "Next",
                          ),
                          const SizedBox(width: 8),
                          Icon(_currentPage == widget.pages.length - 1
                              ? Icons.done
                              : Icons.arrow_forward),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingPageModel {
  final String title;
  final String description;
  final String imageUrl;
  final Color bgColor;
  final Color textColor;

  OnboardingPageModel(
      {required this.title,
        required this.description,
        required this.imageUrl,
        this.bgColor = Colors.blue,
        this.textColor = Colors.black});
}
