//
//  USStates.swift
//  OpenFood
//
//  Created by Thinh Luong on 12/22/15.
//  Copyright © 2015 Thinh Luong. All rights reserved.
//

import Foundation
import MapKit

/// US states in full name
enum USStateFullName: String {
  case Alabama, Alaska, Arizona, Arkansas
  case California, Colorado, Connecticut
  case Delaware, DistrictOfColumbia = "District of Columbia"
  case Florida
  case Georgia
  case Hawaii
  case Idaho, Illinois, Indiana, Iowa
  case Kansas, Kentucky
  case Louisiana
  case Maine, Maryland, Massachusetts, Michigan, Minnesota, Mississippi, Missouri, Montana
  case Nebraska, Nevada, NewHampshire = "New Hampshire", NewJersey = "New Jersey"
  case NewMexico = "New Mexico", NewYork = "New York"
  case NorthCarolina = "North Carolina", NorthDakota = "North Dakota"
  case Ohio, Oklahoma, Oregon
  case Pennsylvania
  case RhodeIsland = "Rhode Island"
  case SouthCarolina = "South Carolina", SouthDakota = "South Dakota"
  case Tennessee, Texas
  case Utah
  case Vermont, Virginia
  case Washington, WestVirginia = "West Virginia", Wisconsin, Wyoming
  
  case US, UnitedStates = "United States", Nationwide
  
  static let allValues = [
    Alabama, Alaska, Arizona, Arkansas, California,
    Colorado, Connecticut, Delaware, DistrictOfColumbia, Florida,
    Georgia, Hawaii, Idaho, Illinois, Indiana,
    Iowa, Kansas, Kentucky, Louisiana, Maine,
    Maryland, Massachusetts, Michigan, Minnesota, Mississippi,
    Missouri, Montana, Nebraska, Nevada, NewHampshire,
    NewJersey, NewMexico, NewYork, NorthCarolina, NorthDakota,
    Ohio, Oklahoma, Oregon, Pennsylvania, RhodeIsland,
    SouthCarolina, SouthDakota, Tennessee, Texas, Utah,
    Vermont, Virginia, Washington, WestVirginia, Wisconsin,
    Wyoming, US, UnitedStates, Nationwide
  ]
  
}

/// US states in abbreviation
enum USStateAbbreviation: String {
  case AL, AK, AS, AZ, AR
  case CA, CO, CT
  case DE, DC, FL, GA, HI
  case ID, IL, IN, IA
  case KS, KY, LA
  case ME, MD, MA, MI, MN, MS, MO, MT
  case NE, NV, NH, NJ, NM, NY, NC, ND
  case OH, OK, OR
  case PA, PR, RI
  case SC, SD
  case TN, TX
  case UT
  case VT, VA
  case WA, WV, WI, WY
  
  case Nationwide
  
  static let allValues = [
    AL, AK, AZ, AR, CA,
    CO, CT, DE, DC, FL,
    GA, HI, ID, IL, IN,
    IA, KS, KY, LA, ME,
    MD, MA, MI, MN, MS,
    MO, MT, NE, NV, NH,
    NJ, NM, NY, NC, ND,
    OH, OK, OR, PA, RI,
    SC, SD, TN, TX, UT,
    VT, VA, WA, WV, WI,
    WY
  ]
}

/**
 Retrieve the polygons for all US states.
 
 - returns: array of polygon of all US states
 */
func polygonsForNationwide() -> [MKPolygon] {
  var polygons = [MKPolygon]()
  
  for state in USStateAbbreviation.allValues {
    polygons.append(polygonForState(state))
  }
  
  return polygons
}

/**
 Retrieve the polygon for specified US state.
 
 - parameter state: US state
 
 - returns: polygon of US state
 */
func polygonForState(state: USStateAbbreviation) -> MKPolygon {
  switch state {
  case .AL: return polygonForAlabama()
  case .AK: return polygonForAlaska()
  case .AZ: return polygonForArizona()
  case .AR: return polygonForArkansas()
  case .CA: return polygonForCalifornia()
  case .CO: return polygonForColorado()
  case .CT: return polygonForConnecticut()
  case .DE: return polygonForDelaware()
  case .DC: return MKPolygon()
  case .FL: return polygonForFlorida()
  case .GA: return polygonForGeorgia()
  case .HI: return polygonForHawaii()
  case .ID: return polygonForIdaho()
  case .IL: return polygonForIllinois()
  case .IN: return polygonForIndiana()
  case .IA: return polygonForIowa()
  case .KS: return polygonForKansas()
  case .KY: return polygonForKentucky()
  case .LA: return polygonForLouisiana()
  case .ME: return polygonForMaine()
  case .MD: return polygonForMaryland()
  case .MA: return polygonForMassachusetts()
  case .MI: return polygonForMichigan()
  case .MN: return polygonForMinnesota()
  case .MS: return polygonForMississippi()
  case .MO: return polygonForMissouri()
  case .MT: return polygonForMontana()
  case .NE: return polygonForNebraska()
  case .NV: return polygonForNevada()
  case .NH: return polygonForNewHampshire()
  case .NJ: return polygonForNewJersey()
  case .NM: return polygonForNewMexico()
  case .NY: return polygonForNewYork()
  case .NC: return polygonForNorthCarolina()
  case .ND: return polygonForNorthDakota()
  case .OH: return polygonForOhio()
  case .OK: return polygonForOklahoma()
  case .OR: return polygonForOregon()
  case .PA: return polygonForPennsylvania()
  case .RI: return polygonForRhodeIsland()
  case .SC: return polygonForSouthCarolina()
  case .SD: return polygonForSouthDakota()
  case .TN: return polygonForTennessee()
  case .TX: return polygonForTexas()
  case .UT: return polygonForUtah()
  case .VA: return polygonForVirginia()
  case .VT: return polygonForVermont()
  case .WA: return polygonForWashington()
  case .WI: return polygonForWisconsin()
  case .WV: return polygonForWestVirginia()
  case .WY: return polygonForWyoming()
  default: return MKPolygon()
  }
}

/**
 Convert US state from full name to abbreviation.
 
 - parameter state: US state
 
 - returns: abbreviated US state
 */
func convertUSStateFullNameToAbbreviation(state: USStateFullName) -> USStateAbbreviation {
  let abbreviation: USStateAbbreviation
  
  switch state {
  case .Alabama: abbreviation            = .AL
  case .Alaska: abbreviation             = .AK
  case .Arizona: abbreviation            = .AZ
  case .Arkansas: abbreviation           = .AR
  case .California: abbreviation         = .CA
  case .Colorado: abbreviation           = .CO
  case .Connecticut: abbreviation        = .CT
  case .Delaware: abbreviation           = .DE
  case .DistrictOfColumbia: abbreviation = .DC
  case .Florida: abbreviation            = .FL
  case .Georgia: abbreviation            = .GA
  case .Hawaii: abbreviation             = .HI
  case .Idaho: abbreviation              = .ID
  case .Illinois: abbreviation           = .IL
  case .Indiana: abbreviation            = .IN
  case .Iowa: abbreviation               = .IA
  case .Kansas: abbreviation             = .KS
  case .Kentucky: abbreviation           = .KY
  case .Louisiana: abbreviation          = .LA
  case .Maine: abbreviation              = .ME
  case .Maryland: abbreviation           = .MD
  case .Massachusetts: abbreviation      = .MA
  case .Michigan: abbreviation           = .MI
  case .Minnesota: abbreviation          = .MN
  case .Mississippi: abbreviation        = .MS
  case .Missouri: abbreviation           = .MO
  case .Montana: abbreviation            = .MT
  case .Nebraska: abbreviation           = .NE
  case .Nevada: abbreviation             = .NV
  case .NewHampshire: abbreviation       = .NH
  case .NewJersey: abbreviation          = .NJ
  case .NewMexico: abbreviation          = .NM
  case .NewYork: abbreviation            = .NY
  case .NorthCarolina: abbreviation      = .NC
  case .NorthDakota: abbreviation        = .ND
  case .Ohio: abbreviation               = .OH
  case .Oklahoma: abbreviation           = .OK
  case .Oregon: abbreviation             = .OR
  case .Pennsylvania: abbreviation       = .PA
  case .RhodeIsland: abbreviation        = .RI
  case .SouthCarolina: abbreviation      = .SC
  case .SouthDakota: abbreviation        = .SD
  case .Tennessee: abbreviation          = .TN
  case .Texas: abbreviation              = .TX
  case .Utah: abbreviation               = .UT
  case .Vermont: abbreviation            = .VT
  case .Virginia: abbreviation           = .VA
  case .Washington: abbreviation         = .WA
  case .WestVirginia: abbreviation       = .WV
  case .Wisconsin: abbreviation          = .WI
  case .Wyoming: abbreviation            = .WY
  case .US: abbreviation                 = .Nationwide
  case .UnitedStates: abbreviation       = .Nationwide
  case .Nationwide: abbreviation         = .Nationwide
  }
  
  return abbreviation
}
