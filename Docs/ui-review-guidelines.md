# 🎨 UI Feature - How To Review

## About This Document

This guide gives you some advice about how to review a UI feature.
It is a simple list of stuff to check to ensure the feature respect our quality guidelines.
The list is not supposed to be exhaustive. It is based on the mistakes we made in the past and on what we have learned along the way.

This document will be useful to you as a reviewer, but also as a developer when you are working on a UI feature.

If you have any ideas to complete this list, feel free to suggest improvements 🙏

## What You Should Check

1. **Figma Compliance:** The views must conform to what was expected by the UI/UX team. Colors and margins must be correct.
2. **UI Readability:** The main advantage of SwiftUI is its declarative syntax, making views easy to read/understand. The code should be easy to read to anyone.
3. **Edge Cases:** We sometimes tend to forget to check what happens when a string is too long, when there are too many items to display… It is a good practice to check that these cases are well handled by the UI.
4. **Error Cases:** When an error may occur in the user flow *(for example an incorrect input)*, check that adequate behavior is implemented.
5. **Dark Mode:** The iOS team is a light mode team. But we must not forget the dark mode, and carefully check that the colors are correct.
6. **Accessibility:** The view should work correctly if the user has decided to scale the font. The components should have an accessibility label when necessary *(for example a button with an image but no text)*.
7. **Device Layouts:** The view should display correctly on both an iPhone 8 and an iPhone 15.
8. **iPad:** Do not forget the iPad. Does the view display correctly on a larger screen?
9. **Run The Code**: Please do not accept a PR without testing it 🙏. Testing it is essential.
