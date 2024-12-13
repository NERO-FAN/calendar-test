import SwiftUI

struct ScheduleView: View {
    @StateObject private var viewModel: ScheduleViewModel
    @StateObject private var userObj: AuthService
    let timeSlots = Array(0..<24)
    
    init(viewModel: ScheduleViewModel = ScheduleViewModel(), userObj: AuthService = AuthService()) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _userObj = StateObject(wrappedValue: userObj)
    }

    @State private var currentTimeSlot: Int = {
        let calendar = Calendar.current
        let now = Date()
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        return (hour * 4) + (minute / 15)
    }()
    @State private var currentDayIndex: Int = Calendar.current.component(.weekday, from: Date()) - 1
    @State private var currentDate = Date()
    @State private var showCalendar = false

    private let calendar = Calendar.current

    private var monthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentDate)
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d'\(daySuffix)'"
        return formatter.string(from: currentDate)
    }

    private var daySuffix: String {
        let day = calendar.component(.day, from: currentDate)
        switch day {
        case 11, 12, 13: return "th"
        default:
            switch day % 10 {
            case 1: return "st"
            case 2: return "nd"
            case 3: return "rd"
            default: return "th"
            }
        }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                if viewModel.isLoading {
                    ProgressView("Loading schedule...")
                        .padding(30)
                } else if let schedule = viewModel.schedule {
                    //Nav Header
                    HStack {
                        Button(action: {
                            navigateToPreviousDay()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }

                        Spacer()

                        Text(monthString)
                            .font(.largeTitle.bold())
                            .foregroundColor(.primary)

                        Spacer()

                        Button(action: {
                            navigateToNextDay()
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 20)

                    Text(formattedDate)
                        .font(.headline)
                        .padding(.bottom)
                        .frame(maxWidth: .infinity, alignment: .center)

                    Spacer()

                    //Main Schedule View
                    ZStack(alignment: .leading) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            VStack(spacing: 0) {
                                ScrollViewReader { verticalProxy in
                                    ScrollView(.vertical, showsIndicators: false) {
                                        HStack(spacing: 0) {
                                            TimeColumn()
                                                .frame(width: 45)

                                            EventsFlow(viewModel: viewModel, currentDate: currentDate)
                                                .frame(maxWidth: .infinity)
                                        }
                                        .onAppear {
                                            withAnimation {
                                                verticalProxy.scrollTo(currentTimeSlot + 5, anchor: .leading)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .frame(maxHeight: .infinity)
                    }
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(30)
                } else {
                    Text("No schedule to display")
                        .foregroundColor(.gray)
                        .padding(30)
                }
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 0)
            }
            .onAppear {
                viewModel.fetchSchedule(id: "-OBzdLE_JS-pxdgALnIL")
            }

            //Add Button
            HStack(spacing: 20) {
                //Cal Button
                Button(action: {
                    showCalendar.toggle()
                }) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 75, height: 75)
                        .overlay(
                            Image(systemName: "calendar")
                                .foregroundColor(.white)
                                .font(.system(size: 30, weight: .bold))
                        )
                        .shadow(radius: 5)
                }

                //Add Event Button
                Button(action: {
                    viewModel.togglePopUp()
                }) {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 75, height: 75)
                        .overlay(
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .font(.system(size: 30, weight: .bold))
                        )
                        .shadow(radius: 5)
                }
            }
            .padding(.trailing, 30)
            .padding(.bottom, 30)

            //Pop-up
            if viewModel.showPopUp {
                PopUpView(
                    isShowing: $viewModel.showPopUp,
                    scheduleId: "-OBzdLE_JS-pxdgALnIL",
                    viewModel: viewModel
                )
                .transition(.scale)
            }

            //Cal View
            if showCalendar {
                VStack {
                    DatePicker(
                        "",
                        selection: $currentDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 10)
                    .padding()

                    Button("View Schedule") {
                        showCalendar = false
                        currentDayIndex = Calendar.current.component(.weekday, from: currentDate) - 1
                        viewModel.fetchSchedule(id: "-OBzdLE_JS-pxdgALnIL")
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .background(Color.black.opacity(0.5))
                .edgesIgnoringSafeArea(.all)
                .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: showCalendar)
    }

    //Navigation Methods
    private func navigateToNextDay() {
        currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        currentDayIndex = (currentDayIndex + 1) % 7
        viewModel.fetchSchedule(id: "-OBzdLE_JS-pxdgALnIL")
    }

    private func navigateToPreviousDay() {
        currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        currentDayIndex = (currentDayIndex - 1 + 7) % 7
        viewModel.fetchSchedule(id: "-OBzdLE_JS-pxdgALnIL")
    }
}

struct TimeColumn: View {
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<96) { timeSlot in
                if timeSlot % 4 == 0 {
                    Text("\(timeSlot / 4):00")
                        .font(.title3)
                        .frame(height: 62)
                        .id(timeSlot)
                        .foregroundColor(.secondary)
                } else {
                    Text("")
                        .frame(height: 62)
                        .id(timeSlot)
                }
            }
        }
        .frame(width: 45)
        .background(Color(UIColor.systemGray6))
    }
}

struct EventsFlow: View {
    @StateObject var viewModel: ScheduleViewModel
    let currentDate: Date

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    ForEach(0..<24) { _ in
                        Rectangle()
                            .stroke(Color.gray.opacity(0.3))
                            .frame(width: 312, height: 250)
                            .cornerRadius(10)
                    }
                }

                if let events = viewModel.events {
                    ForEach(events.filter { event in
                        let eventDate = Date(timeIntervalSince1970: event.startTime)
                        let isSameDay = Calendar.current.isDate(eventDate, inSameDayAs: currentDate)
                        return isSameDay
                    }) { event in
                        let position = viewModel.calculatePosition(event: event)
                        EventCell(event: event)
                            .frame(width: 312)
                            .frame(height: position.height)
                            .offset(y: position.offset)
                    }
                }
            }
            .frame(width: 312)
        }
    }
}


struct EventCell: View {
    let event: Event

    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.blue.opacity(0.3))
            .overlay(
                Text(event.title)
                    .font(.body)
                    .padding(10)
                    .foregroundColor(.primary)
            )
            .padding(.horizontal, 10)
            .shadow(radius: 6)
            .padding(.vertical, 6)
    }
}

#Preview {
    ScheduleView(viewModel: ScheduleViewModel(), userObj: AuthService())
}
