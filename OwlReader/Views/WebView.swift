//
//  Webview.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/04/22.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable, Equatable {
    
    static func == (lhs: WebView, rhs: WebView) -> Bool {
        lhs.url == rhs.url && lhs.webView == rhs.webView
    }

    let url: URL?
    @ObservedObject var viewModel: ProgressVM
    
    @Binding var webView: WKWebView?
    var didFinishLoadingThisURL: ((Link?) -> Void)?
    var onWordSelected: (String) -> Void

   func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences.allowsContentJavaScript = true
       
       // Load content blocker rules
       if let rulesPath = Bundle.main.path(forResource: "contentBlockerRules", ofType: "json"),
          let rulesData = try? Data(contentsOf: URL(fileURLWithPath: rulesPath)),
          let rulesString = String(data: rulesData, encoding: .utf8) {
           WKContentRuleListStore.default().compileContentRuleList(forIdentifier: "ContentBlockingRules", encodedContentRuleList: rulesString) { contentRuleList, error in
               if let contentRuleList = contentRuleList {
                   config.userContentController.add(contentRuleList)
               } else if let error = error {
                   print("Failed to compile content rule list: \(error)")
               }
           }
       } else {
           print("Failed to load content blocker rules")
       }
       
        let userScriptSource = """
        var currentHighlightedWord = null;
        document.addEventListener('click', function(event) {
            // Get the clicked target element
            var target = event.target;
            
            // Check if the clicked target or its ancestors are links (<a> tag)
            var isInLink = false;
            var currentElement = target;
            while (currentElement) {
                if (currentElement.nodeName === 'A') {
                    // The target or its parent is an anchor element
                    isInLink = true;
                    break;
                }
                currentElement = currentElement.parentNode;
            }
        
            // If the clicked target is in a link, allow the default navigation behavior
            // and do not process further
            if (isInLink) {
                return
            }
        
            // Get the clicked coordinates
            var clientX = event.clientX;
            var clientY = event.clientY;
        
            // Get the range at the clicked position
            var range = document.caretRangeFromPoint(clientX, clientY);
        
            // If range is null, return early
            if (!range) {
                return;
            }
        
            // Expand the range to the nearest word
            expandRangeToWord(range);
        
            // Wrap the word in a span element with background color
            var newHighlightedWord = wrapRangeInSpan(range, 'orange'); // Change the color here
        
        if (currentHighlightedWord) {
                currentHighlightedWord.style.backgroundColor = '';
            }
        
            // Update the reference to the currently highlighted word
            currentHighlightedWord = newHighlightedWord;
        
            // Create a selection object and add the range
            var selection = window.getSelection();
            selection.removeAllRanges();
            selection.addRange(range);
        
            // Get the selected word
            var selectedWord = selection.toString().trim();
        
            // Send the selected word to Swift
            if (selectedWord.length > 0) {
                window.webkit.messageHandlers.wordSelected.postMessage(selectedWord);
            }
        });
        
        // Function to expand the range to include the nearest word
        function expandRangeToWord(range) {
            // Expand the start of the range to the left
            while (range.startOffset > 0) {
                range.setStart(range.startContainer, range.startOffset - 1);
                var charBefore = range.toString().slice(0, 1);
                if (charBefore.match(/\\s/)) {
                    range.setStart(range.startContainer, range.startOffset + 1);
                    break;
                }
            }
        
            // Expand the end of the range to the right
            while (range.endOffset < range.endContainer.length) {
                range.setEnd(range.endContainer, range.endOffset + 1);
                var charAfter = range.toString().slice(-1);
                if (charAfter.match(/\\s/)) {
                    range.setEnd(range.endContainer, range.endOffset - 1);
                    break;
                }
            }
        }
        
        // Function to wrap the range in a span element with a background color
        function wrapRangeInSpan(range, color) {
            // Create a span element
            var span = document.createElement('span');
            span.style.backgroundColor = color;
        
            // Surround the selected word with the span
            range.surroundContents(span);
        
        // Return the span element
            return span;
        }
        """
        
        let userScript = WKUserScript(
            source: userScriptSource,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        config.userContentController.addUserScript(userScript)
        
        // Correctly pass the Coordinator instance to add
        config.userContentController.add(context.coordinator, name: "wordSelected")
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.addObserver(context.coordinator, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
       
       DispatchQueue.main.async {
           self.webView = webView
       }
       if let myURL = url {
           let request = URLRequest(url: myURL)
           webView.load(request)
       }
       return webView
   }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Method to filter a string to contain only letters
        func filterToOnlyLetters(_ string: String) -> String {
            // Define a CharacterSet for letters
            let letters = CharacterSet.letters
            
            // Filter the string to retain only letters
            let filteredString = string.filter { character in
                return letters.contains(character.unicodeScalars.first!)
            }
            
            return filteredString
        }
    
    
    class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
        var parent: WebView
    
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
                    if keyPath == "estimatedProgress" {
                        if let webView = object as? WKWebView {
                            DispatchQueue.main.async {
                                self.parent.viewModel.progress = webView.estimatedProgress
//                                print("\(self.parent.viewModel.progress)")
                            }
                        }
                    }
                }
        
        // Make sure the Coordinator conforms to WKScriptMessageHandler
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "wordSelected", let selectedWord = message.body as? String {
                
                // Filter the selected word to contain only letters
                let filteredWord = parent.filterToOnlyLetters(selectedWord)
                
                // Call the onWordSelected closure with the filtered word
                parent.onWordSelected(filteredWord)
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if let currentURL = webView.url, let currentTitle = webView.title {
                parent.didFinishLoadingThisURL?(Link(url: currentURL, webPageTitle: currentTitle))
                print("Finished navigating to url \(String(describing: webView.url))")
                print("\(String(describing: webView.title))")
            }
        }
    }
}


