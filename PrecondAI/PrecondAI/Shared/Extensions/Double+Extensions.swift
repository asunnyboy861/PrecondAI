import Foundation

extension Double {
    var fahrenheitToCelsius: Double {
        (self - 32) * 5 / 9
    }

    var celsiusToFahrenheit: Double {
        self * 9 / 5 + 32
    }
}
