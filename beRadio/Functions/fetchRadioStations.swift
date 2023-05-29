import Foundation

func fetchRadioStations(genre: String, name: String, country: String, state: String, completion: @escaping ([RadioStation]) -> Void) {

    func longestWord(in string: String) -> String {
        let words = string.components(separatedBy: .whitespaces)
        if let longestWord = words.max(by: { $1.count > $0.count }) {
            return longestWord
        } else {
            return ""
        }
    }

    func filterStations(filteredArray: [RadioStation], filteringArray: [String]) -> [RadioStation] {
        return filteredArray.filter { element in
            filteringArray.allSatisfy { filterElement in
                element.name.lowercased().contains(filterElement.lowercased())
            }
        }
    }

    var encodedSearchString = ""
    if !name.isEmpty {
        let name = longestWord(in: name)
        let encodedSearchName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name
        encodedSearchString = "name=" + encodedSearchName
    }
    if !genre.isEmpty {
        let encodedSearchGenre = genre.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? genre
        encodedSearchString = "name=" + encodedSearchGenre
    }
    if !country.isEmpty {
        if !encodedSearchString.isEmpty {
            encodedSearchString += "&"
        }
        let encodedSearchCountry = country.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? country
        encodedSearchString += "country=" + encodedSearchCountry
    }
    if !encodedSearchString.isEmpty {
        encodedSearchString = "?" + encodedSearchString
    }

    guard let url = URL(string: "https://de1.api.radio-browser.info/json/stations/search\(encodedSearchString)") else {
        print("Invalid URL")
        return
    }

    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let data = data {
            let decoder = JSONDecoder()

            if var stations = try? decoder.decode([RadioStation].self, from: data) {
                DispatchQueue.main.async {
                    let name = name.trimmingCharacters(in: .whitespaces)
                    var search = name
                    if !genre.isEmpty && name != genre && name.contains(genre) {
                        search = name.replacingOccurrences(of: genre, with: "").lowercased()
//                        stations = stations.filter { $0.name.lowercased().contains(search) }
                    }
                    if !search.isEmpty {
                        stations = filterStations(filteredArray: stations, filteringArray: search.components(separatedBy: " "))
                    }
                    stations = Array(stations.prefix(100))
                    if !state.isEmpty && !country.isEmpty {
                        stations.sort { station1, station2 in
                            let matches1 = station1.state == state && station1.country == country
                            let matches2 = station2.state == state && station2.country == country
                            return matches1 && !matches2
                        }
                    }
                    stations.sort { station1, station2 in
                        let matches1 = station1.favicon != ""
                        let matches2 = station2.favicon != ""
                        return matches1 && !matches2
                    }
                    completion(stations)
                }
                return
            }
        }
        print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
    }
    task.resume()
}

