//
//  ContentView.swift
//  ReUpcycleHome
//
//  Created by Niveta Sree G on 11/10/24.
//

import SwiftUI
import AVFoundation

// Main ContentView with Navigation
struct ContentView: View {
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            // Welcome screen
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                VStack {
                    Text("Welcome to MyApp")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.bottom, 40)

                    // Get Started Button - Navigate to HomeView
                    Button(action: {
                        navigationPath.append(NavigationItem.home)
                    }) {
                        Text("Get Started")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                }
            }
            // Navigation destinations
            .navigationDestination(for: NavigationItem.self) { item in
                switch item {
                case .home:
                    HomeView(navigationPath: $navigationPath)
                case .recycle:
                    DisplayCapturedImageView()
                case .learnMore:
                    LearnMoreView()
                case .upcycle:
                    UpcycleSuggestionView()
                case .help:
                    HelpView()
                }
            }
        }
    }
}

// Enum for Navigation Items
enum NavigationItem: Hashable {
    case home
    case recycle
    case upcycle
    case learnMore
    case help
}

// Helper function to run a Python script
func runPythonScript(withImageAt imagePath: String) {
    let task = Process()
    task.launchPath = "/usr/bin/python3"
    task.arguments = ["/Users/nivetag/Downloads/process_image.py", imagePath]

    let pipe = Pipe()
    task.standardOutput = pipe

    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)
    print("Python script output: \(output ?? "No output")")
}

// Helper function to save an image to disk
func saveImageToDisk(image: NSImage, filename: String) -> URL? {
    guard let tiffData = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffData),
          let pngData = bitmap.representation(using: .png, properties: [:]) else {
        return nil
    }

    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    let fileURL = documentsDirectory?.appendingPathComponent(filename)

    do {
        try pngData.write(to: fileURL!)
        return fileURL
    } catch {
        print("Error saving image: \(error)")
        return nil
    }
}

struct HomeView: View {
    @Binding var navigationPath: NavigationPath

    var body: some View {
        VStack(spacing: 20) {
            Text("Home Screen")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            Button(action: {
                navigationPath.append(NavigationItem.upcycle)
            }) {
                HStack {
                    Image(systemName: "arrow.2.circlepath")
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("Upcycle")
                        .font(.headline)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.horizontal, 40)

            Button(action: {
                navigationPath.append(NavigationItem.learnMore)
            }) {
                HStack {
                    Image(systemName: "info.circle")
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("Learn More")
                        .font(.headline)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 5)
            }
            .padding(.horizontal, 40)

            Button(action: {
                navigationPath.append(NavigationItem.help)
            }) {
                HStack {
                    Image(systemName: "questionmark.circle")
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("Help")
                        .font(.headline)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 5)
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }
}

struct LearnMoreView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Learn More About Recycling and Upcycling")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)

                Text("""
                Recycling and upcycling are essential practices that help us manage waste and protect our environment...
                """)
                .font(.system(.body, design: .serif))
                .padding(.horizontal, 20)
                Spacer()
            }
            .padding(.horizontal)
        }
        .navigationTitle("Learn More")
    }
}

struct HelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Help & Support")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)

                Text("""
                Welcome to the Help section! RecycoHome is fairly simple to use...
                """)
                .font(.body)
                .padding(.horizontal, 20)
                Spacer()
            }
            .padding(.horizontal)
        }
        .navigationTitle("Help")
    }
}

// UpcycleSuggestionView
struct UpcycleSuggestionView: View {
    @State private var wasteType: String = ""
    @State private var suggestions: String = ""
    @State private var isLoading = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Upcycle Suggestions")
                .font(.largeTitle)
                .padding(.top)

            TextField("Enter the waste type (e.g., plastic bottle)", text: $wasteType)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                isLoading = true
                getUpcyclingSuggestions(for: wasteType) { result in
                    suggestions = result
                    isLoading = false
                }
            }) {
                Text("Get Suggestions")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()

            if isLoading {
                ProgressView("Loading...")
            }

            Text(suggestions)
                .padding()
                .font(.body)
                .multilineTextAlignment(.leading)
        }
        .padding()
    }

    // Simulated function to get upcycling suggestions
    func getUpcyclingSuggestions(for wasteType: String, completion: @escaping (String) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completion("Example suggestions for \(wasteType)")
        }
    }
}

struct DisplayCapturedImageView: View {
    var image: NSImage?

    var body: some View {
        VStack {
            if let image = image {
                Image(nsImage: image) // Display the captured image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
            } else {
                Text("No image captured")
            }
        }
        .navigationTitle("Captured Image")
    }
}
