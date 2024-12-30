import SwiftUI

struct buttonType: Comparable  {
    
    var text: String
    var buttonFunc: Int
    var color: Color
    
    init(text: String, buttonFunc: Int, color: Color) {
        self.text = text
        self.buttonFunc = buttonFunc
        self.color = color
    }
    
    static func <(lhs: buttonType, rhs: buttonType) -> Bool {
        return lhs.text < rhs.text
    }
    
    static func == (lhs: buttonType, rhs: buttonType) -> Bool {
        return lhs.text == rhs.text
    }
}

struct PoolGameView: View {
    let numPlayers = 2
    var actionButtons: [buttonType] = []
    @ObservedObject var gameData: GameData
    @ObservedObject var initialGameData = GameData(id: 0, players: [])
    @ObservedObject var gameManager = GameManager()
    
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State private var isImagePickerDisplay = false
    @State private var photoTapped = false
    @State private var isSaving = false
    
    @State private var currentLongestStreak = 0
    @State private var isPresentingHomeView = false
    
    @State private var buttonsPressed: [Int] = []

    
    init(gameData: GameData) {
        self.gameData = gameData
        self.initialGameData.setValues(newGameData: self.gameData)
        actionButtons = [buttonType(text: "Potted\nRegular Ball", buttonFunc: 0, color: .blue),
                         buttonType(text: "Gilled\nRegular Ball", buttonFunc: 2, color: .green),
                         buttonType(text: "Fouled\nRegular", buttonFunc: 4, color: .red),
                         buttonType(text: "Potted\nBlack Ball", buttonFunc: 1, color: .blue),
                         buttonType(text: "Gilled\nBlack Ball", buttonFunc: 3, color: .green),
                         buttonType(text: "Fouled\nBlack", buttonFunc: 5, color: .red),
                         buttonType(text: "Undo", buttonFunc: 6, color: .orange),
                         buttonType(text: "Game Over", buttonFunc: 7, color: .orange),
                         buttonType(text: "Fouled\nGill Black", buttonFunc: 8, color: .orange)]
    }
    
    var body: some View {
        HStack {
            VStack {
                Spacer()
                ScrollView {
                    ForEach(Array(self.gameData.players.enumerated()), id: \.element) { index, player in
                        PlayerScoreView(playerName: self.gameData.players[index].name, score: self.gameData.scores[index], isCurrentPlayer: self.gameData.currentPlayer==index).opacity(self.gameData.playersMissingGo.contains(index) ? 0.5 : 1)
                    }
                }
                Spacer()
            }
            Spacer()
            HStack {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 120), spacing: 15), count: 3), spacing: 15) {
                    ForEach(0..<9) { actionID in
                        Button(action: {
                            tookAction(actionType: actionButtons[actionID].buttonFunc, replaying: false)
                        }) {
                            Text("\(actionButtons[actionID].text)")
                                .frame(width:125, height:actionID < 6 ? 90 : 70)
                                .background(actionButtons[actionID].color)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .font(.system(size: actionID < 6 ? 18 : 15))
                        }
                    }
                }
                .padding(5)
            }
            VStack {
                Spacer()
                Button(action: {
                    tookAction(actionType: -1, replaying: false)
                }) {
                    Text("Next Player")
                        .frame(width:100, height:175)
                        .padding()
                        .background(.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(5)
                Spacer()
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                                isPresentingHomeView = true
                        }) {
                            Image(systemName: "house")
                                        .font(.system(size: 30))
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.black)
                                        .cornerRadius(5)
                                        .padding(.bottom, 20)
                        }
                        .sheet(isPresented: $isPresentingHomeView) {
                            NavigationView {
                                HomeScreen()
                            }
                        }
                        Spacer()
                        Button(action: {
                            self.rotate(rotation: UIInterfaceOrientation.portrait)
                            self.sourceType = .camera
                            self.isImagePickerDisplay.toggle()
                        }) {
                            Image(systemName: "camera")
                                .font(.system(size: 30))
                                .frame(width: 50, height: 50)
                                .foregroundColor(.black)
                                .cornerRadius(5)
                        }
                        Spacer()
                    }
                    HStack {
                        Button(action: {
                            self.gameManager.saveGame(gameData: self.gameData)
                        }) {
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 30))
                                .frame(width: 50, height: 50)
                                .foregroundColor(.black)
                                .cornerRadius(5)
                        }
                        if gameData.whiteBallPhoto != nil {
                            Image(uiImage: gameData.whiteBallPhoto!)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                                .onTapGesture {
                                    self.photoTapped.toggle()
                                }
                                .popover(isPresented: $photoTapped) {
                                    Image(uiImage: gameData.whiteBallPhoto!)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 500, height: 300)
                                        .onTapGesture {
                                            self.photoTapped.toggle()
                                        }
                                }
                        }
                    }
                }
            }
        }
        .fullScreenCover(isPresented: self.$isImagePickerDisplay, content: {
            ImagePickerView(selectedImage: self.$gameData.whiteBallPhoto, sourceType: self.sourceType)
                    })
    }
    
    
    func tookAction(actionType: Int, replaying: Bool) {
        if gameData.isGameOver {
            return
        }
        if !replaying {
            self.buttonsPressed.append(actionType)
        }	
        switch actionType {
            // potted regular
            case 0:
                self.gameData.stats[self.gameData.currentPlayer]["Regular Pots"]! += 1
                self.gameData.pottedRegular(gilled: false)
                self.currentLongestStreak += 1
            // potted black
            case 1:
                self.gameData.stats[self.gameData.currentPlayer]["Black Pots"]! += 1
                self.gameData.pottedBlack(gilled: false)
                self.currentLongestStreak += 1
            // gilled regular
            case 2:
                self.gameData.stats[self.gameData.currentPlayer]["Regular Gills"]! += 1
                self.gameData.pottedRegular(gilled: true)
                self.currentLongestStreak += 1
            // gilled black
            case 3:
                self.gameData.stats[self.gameData.currentPlayer]["Black Gills"]! += 1
                self.gameData.pottedBlack(gilled: true)
                self.currentLongestStreak += 1
            // fouled regular
            case 4:
                self.gameData.stats[self.gameData.currentPlayer]["Regular Fouls"]! += 1
                self.gameData.stats[self.gameData.currentPlayer]["Turns"]! += 1
                if self.currentLongestStreak > self.gameData.stats[self.gameData.currentPlayer]["Longest Potting Streak"]! {
                    self.gameData.stats[self.gameData.currentPlayer]["Longest Potting Streak"] = self.currentLongestStreak
                }
                self.gameData.fouledRegular()
                self.currentLongestStreak = 0
            // fouled black
            case 5:
                self.gameData.stats[self.gameData.currentPlayer]["Black Fouls"]! += 1
                self.gameData.stats[self.gameData.currentPlayer]["Turns"]! += 1
                self.gameData.fouledBlack(gilled: false)
                if self.currentLongestStreak > self.gameData.stats[self.gameData.currentPlayer]["Longest Potting Streak"]! {
                    self.gameData.stats[self.gameData.currentPlayer]["Longest Potting Streak"] = self.currentLongestStreak
                }
                self.currentLongestStreak = 0
            // next player
            case -1:
                self.gameData.stats[self.gameData.currentPlayer]["Turns"]! += 1
                if self.currentLongestStreak > self.gameData.stats[self.gameData.currentPlayer]["Longest Potting Streak"]! {
                    self.gameData.stats[self.gameData.currentPlayer]["Longest Potting Streak"] = self.currentLongestStreak
                }
                self.gameData.nextPlayer()
                self.currentLongestStreak = 0
            // undo previous action
            case 6:
                //TODO
                print("Undo previous action")
                self.gameData.setValues(newGameData: self.initialGameData)
                self.buttonsPressed = self.buttonsPressed.dropLast(2)
                for actionTaken in self.buttonsPressed {
                    tookAction(actionType: actionTaken, replaying: true)
                }
            // game over
            case 7:
                self.gameData.stats[self.gameData.currentPlayer]["Turns"]! += 1
                if self.currentLongestStreak > self.gameData.stats[self.gameData.currentPlayer]["Longest Potting Streak"]! {
                    self.gameData.stats[self.gameData.currentPlayer]["Longest Potting Streak"] = self.currentLongestStreak
                }
                self.currentLongestStreak = 0
                self.gameData.gameOver()
                self.gameManager.saveGame(gameData: self.gameData)
            // fouled gill black
            case 8:
                self.gameData.stats[self.gameData.currentPlayer]["Black Fouls"]! += 1
                self.gameData.stats[self.gameData.currentPlayer]["Turns"]! += 1
                if self.currentLongestStreak > self.gameData.stats[self.gameData.currentPlayer]["Longest Potting Streak"]! {
                    self.gameData.stats[self.gameData.currentPlayer]["Longest Potting Streak"] = self.currentLongestStreak
                }
                self.currentLongestStreak = 0
                self.gameData.fouledBlack(gilled: true)
            default:
                print("action not defined")
        }
    }
    
    func rotate(rotation: UIInterfaceOrientation) -> Void {
            let value = rotation.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }
}


struct PlayerScoreView: View {
    let playerName: String
    var score: Int
    var isCurrentPlayer: Bool
    
    var body: some View {
        HStack {
            Text(playerName)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.leading)
                .font(.system(size: 500))
                .minimumScaleFactor(0.01)
                .lineLimit(1)
            Spacer()
            Text("\(score)")
                .font(.title)
                .foregroundColor(.white)
                .font(.system(size: 500))
                .minimumScaleFactor(0.01)
                .lineLimit(1)
                .padding(3)
        }
        .frame(width: 125, height: 40)
        .background(isCurrentPlayer ? Color.blue : Color.gray)
        .cornerRadius(10)
        .shadow(radius: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black, lineWidth: isCurrentPlayer ? 2 : 0)
        )
        .padding(5)
    }
}



struct ImagePickerView: UIViewControllerRepresentable {
    
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var isPresented
    var sourceType: UIImagePickerController.SourceType
        
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = self.sourceType
        imagePicker.delegate = context.coordinator // confirming the delegate
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {

    }

    // Connecting the Coordinator class with this struct
    func makeCoordinator() -> Coordinator {
        return Coordinator(picker: self)
    }
}

class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var picker: ImagePickerView
    
    init(picker: ImagePickerView) {
        self.picker = picker
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        self.picker.selectedImage = selectedImage
        self.picker.isPresented.wrappedValue.dismiss()
    }
    
}
