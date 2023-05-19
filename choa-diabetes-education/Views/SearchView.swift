//
//  SearchView.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 10/13/22.
//

import UIKit
import Pendo

protocol SearchViewDelegate {
    func closeSearch()
    func closeKeyboard()
    func moveSearchView(expansion: CGFloat)
    func moveSearchToBottom()
}

class SearchView: UIView, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var searchBackground: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchField: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noResultsLabel: UILabel!
    
    var delegate: SearchViewDelegate!
    
    var searchTerm = ""
    var searchContent: String!
    var searchPage = ""
    var isFiltering = false
    var searchResults = Array<Substring>()
    
    //------------------------------------------------------------------------------
    init( frame: CGRect, delegate: SearchViewDelegate, searchPage: String )
    {
        super.init( frame : frame )
        self.delegate = delegate
        self.searchPage = searchPage
        customInit()
    }
    
    //------------------------------------------------------------------------------
    required init?( coder aDecoder: NSCoder )
    {
        super.init( coder : aDecoder )
        
        customInit()
    }
    
    //------------------------------------------------------------------------------
    func customInit()
    {
        let nibView = Bundle.main.loadNibNamed( "SearchView", owner: self, options: nil)!.first as! UIView
        self.addSubview( nibView )
        
        nibView.translatesAutoresizingMaskIntoConstraints = false
        
        nibView.leftAnchor.constraint( equalTo: self.leftAnchor ).isActive = true
        nibView.rightAnchor.constraint( equalTo: self.rightAnchor ).isActive = true
        nibView.topAnchor.constraint( equalTo: self.topAnchor ).isActive = true
        nibView.bottomAnchor.constraint( equalTo: self.bottomAnchor ).isActive = true
        
        searchBackground.layer.cornerRadius = 40
        searchField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "SearchResultTableViewCell", bundle: nil), forCellReuseIdentifier: "searchCell")
        tableView.estimatedRowHeight = 100
        tableView.estimatedRowHeight = UITableView.automaticDimension
        
        let path = Bundle.main.path(forResource: searchPage, ofType: "html")!
        // This converts a multiline string into a single file, the .whitespacesandnewlines doesn't work to do that job
        // Edit for Diabetes specific code: converting characters like EOFs to | so that the search engine can work properly in identifying the breakpoints between sentences
        var htmlString = try! String(contentsOfFile: path).replacingOccurrences(of: "[\\s\n]+", with: " ", options: .regularExpression).trimmingCharacters(in: .whitespacesAndNewlines)
        print(htmlString)
        // This will remove the h3 headers from the search feature **IF THE HEADER CHANGES WE HAVE TO
        //        ADJUST THE CODE
        htmlString = htmlString.replacingOccurrences(of: "<h3>.*?</h3>", with: "", options: .regularExpression, range: nil)
        print(htmlString)
        htmlString = htmlString.replacingOccurrences(of: "<.*?>", with: ". ", options: .regularExpression, range: nil)
        print(htmlString)
        searchContent = htmlString
    }
    
    // Search field and GestureRecognizer not currently working properly, field does not display text and Gesture doesn't trigger anything
    @IBAction func dragDown(_ sender: UIGestureRecognizer){
        delegate.closeSearch()
    }
    
    @IBAction func moveSearchView(_ sender: UIPanGestureRecognizer){
        if let screenheight = self.superview?.frame.height {
            
            let fingerPosition = sender.location(in: self.superview).y
            
            if fingerPosition > screenheight - 100 {
                delegate.closeSearch()
            } else if fingerPosition < 250 {
                delegate.moveSearchView(expansion: screenheight - 300)
            } else {
                delegate.moveSearchView(expansion: screenheight - fingerPosition - 50)
            }
        }
    }
    
    func displaySearchResults(){
        delegate.closeKeyboard()
        tableView.reloadData()
        // Logic for showing the noResultsLabel
        checkForEmptyResults()
        // Load the new height and pass it to the VC
        delegate.moveSearchView(expansion: tableView.contentSize.height)
        // Pendo track what word was searched for
        PendoManager.shared().track("searchQuery", properties: ["searchTerm":searchTerm, "page":searchPage])
    }
    
    // Connect to the search button
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        displaySearchResults()
    }
    
    @IBAction func searchChapter(_ sender: UIButton){
        print("should display data")
        
        displaySearchResults()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        // When user has entered text into the search box
        // Use the filter method to iterate over all items in the data array
        // Change the value of the variable when text changes
        searchTerm = searchText
        // For each item, return true if the item should be included and false if the
        if searchText != ""{
            isFiltering = true
            noResultsLabel.isHidden = true
            // Method B: Segment the html into sentences and display those containing the target word
            // Step 1: Segment the html according to . separators
            let contentArrayed = searchContent.split(separator: ".")
            // Step 2: Filter the array for elements containing keyword
            print(searchText)
            searchResults = contentArrayed.filter({$0.lowercased().contains(searchText.lowercased())})
            // Step 3: Display results in TableView
            print(searchResults)
        } else {
            isFiltering = false
            tableView.reloadData()
        }
        
        /*
         // Method A: TB Reference Guide Style
         // Step 1: Discover how many instances of the term
         let contentArrayed = searchContent.split(separator: " ")
         let contentArrayed2 = searchContent.split(separator: ".")
         print(contentArrayed2)
         let resultsCount = contentArrayed.filter({$0.lowercased() == "insulin"}).count
         print(resultsCount)
         
         // Step 2: Get indexes of the term
         var searchIndexes = [Int]()
         var firstIndex = 0
         for _ in 0...resultsCount-1 {
         if let termIndex = contentArrayed[firstIndex...contentArrayed.count-1].firstIndex(where: { $0.lowercased() == "insulin"}) {
         searchIndexes.append(termIndex)
         firstIndex = termIndex+1
         }
         }
         print(searchIndexes)
         
         // Step 3: Get indexes of EOFs surrounding the search term
         let eofsCount = contentArrayed.filter({$0.lowercased().contains(".")}).count
         var eofsIndexes = [Int]()
         var eofsSurroundingSearchIndex = [[Int]]()
         firstIndex = 0
         var firstSearchIndex = 0
         for _ in 0...eofsCount-1 {
         if let termIndex = contentArrayed[firstIndex...contentArrayed.count-1].firstIndex(where: { $0.lowercased().contains(".")}) {
         eofsIndexes.append(termIndex)
         firstIndex = termIndex+1
         if termIndex > searchIndexes[firstSearchIndex] {
         eofsSurroundingSearchIndex.append([eofsIndexes[eofsIndexes.count-2]+1,termIndex])
         firstSearchIndex += 1
         }
         }
         }
         print(eofsIndexes)
         print(eofsSurroundingSearchIndex)
         
         // Step 4: Get each sentence containig the search term
         for i in 0...searchIndexes.count-1 {
         print(contentArrayed[eofsSurroundingSearchIndex[i][0]...eofsSurroundingSearchIndex[i][1]].joined(separator: " "))
         }
         
         
         // Step 4: Assign each to an entry in a TableView
         */
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        delegate.moveSearchToBottom()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            print(searchResults.count)
            return searchResults.count
        } else {
            return 0
        }
    }
    
    func checkForEmptyResults() {
        if searchResults.count == 0 {
            noResultsLabel.isHidden = false
        } else {
            noResultsLabel.isHidden = true
        }
    }
    
    private func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchResultTableViewCell
        cell.resultContent.text = String(searchResults[indexPath.row]).dropFirst()+"\n"
        cell.resultContent.textColor = UIColor.contentBlackColor
        cell.backgroundColor = UIColor.backgroundColor
        return cell
    }
}
