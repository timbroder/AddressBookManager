//
//  AddressBookPropertyManager.swift
//  Pods
//
//  Created by Aadesh Patel on 5/30/15.
//
//

import Foundation
import AddressBook

class AddressBookPropertyManager: NSObject {
    /**
        Sets single value for address book property
    
        :param: property Property for which value is being set
        :param: value Value of the property
    
        :returns: Error, if one occurs setting a value
    */
    class func setSingleProperty(#record: ABRecord, property: ABPropertyID, value: AnyObject?) -> CFError? {
        var error: Unmanaged<CFError>? = nil
        
        ABRecordSetValue(record, property, value, &error)
        return error?.takeRetainedValue()
    }
    
    /**
        Retrieves single value for address book property
    
        :param: property Property for which single value is being retrieved for
    
        :returns: Single value of the property
    */
    class func getSingleProperty<T>(#record: ABRecord, property: ABPropertyID) -> T? {
        var propertyValue: AnyObject? = ABRecordCopyValue(record, property)?.takeRetainedValue()
        
        return propertyValue as? T
    }
    
    /**
        Sets multi value for address book property
    
        :param: property Property for which multi value is being set
        :param: values Array of MultiValue instances
    */
    class func setMultiValueProperty<T: AnyObject>(#record: ABRecord, property: ABPropertyID, values: Array<MultiValue<T>>?) {
        var multiValueRef: ABMutableMultiValueRef = ABMultiValueCreateMutable(ABPersonGetTypeOfProperty(property)).takeRetainedValue()
        
        for m: MultiValue in values! {
            ABMultiValueAddValueAndLabel(multiValueRef, m.value, m.key, nil)
        }
        
        ABRecordSetValue(record, property, multiValueRef, nil)
    }
    
    /**
        Retrieves multi value for address book property
    
        :param: property Property for which multi value is being retrieved for
    
        :returns: Value of property as an array of multi value instances
    */
    class func getMultiValueProperty<T>(#record: ABRecord, property: ABPropertyID) -> Array<MultiValue<T>>? {
        var propertyValues: Array<MultiValue<T>>?
        let values: ABMultiValue? = self.getSingleProperty(record: record, property: property)
        
        propertyValues = []
        for i: Int in 0..<(ABMultiValueGetCount(values)) {
            if let value: T? = ABMultiValueCopyValueAtIndex(values, i)?.takeRetainedValue() as? T {
                let id: Int = Int(ABMultiValueGetIdentifierAtIndex(values, i))
                let key: String? = ABMultiValueCopyLabelAtIndex(values, i).takeRetainedValue() as String
                let multiValue: MultiValue<T> = MultiValue(id: id, key: key!, value: value)
                
                propertyValues?.append(multiValue)
            }
        }
        
        return propertyValues
    }
    
    /**
        Retrieves multi value dictionary for address book property
    
        :param: property Property for which multi value dictionary is being retrieved for
        :param: convertor Block to convert from type T to type U
    
        :returns: Value of address book property as an array of multi value dictionaries
    */
    class func getMultiValueDictionaryProperty<T,U,V: AnyObject>(
        record: ABRecord,
        property: ABPropertyID,
        convertor: (T) -> U) -> Array<MultiValue<Dictionary<U, V>>>?
    {
        var propertyValues: Array<MultiValue<Dictionary<U, V>>>?
        let values: ABMultiValue? = self.getSingleProperty(record: record, property: property)
        
        propertyValues = []
        for i: Int in 0..<(ABMultiValueGetCount(values)) {
            if let value: Dictionary<String, V>? = ABMultiValueCopyValueAtIndex(values, i).takeRetainedValue() as? Dictionary<String, V> {
                let id: Int = Int(ABMultiValueGetIdentifierAtIndex(values, i))
                let key: String? = ABMultiValueCopyLabelAtIndex(values, i).takeRetainedValue() as String
                
                var newValue = Dictionary<U, V>()
                for (k, v) in value! {
                    newValue[convertor(k as! T) as U] = v
                }
                
                let multiValue: MultiValue<Dictionary<U, V>> = MultiValue(id: id, key: key!, value: newValue)
                propertyValues?.append(multiValue)
            }
        }
        
        return propertyValues
    }
}

/**
    AddressPropertys to access components of an address
*/
public enum AddressProperty {
    case Street
    case City
    case State
    case ZipCode
    case Country
    case CountryCode

    
    /**
        Get AddressProperty value from kABPersonAddressKey String input

        :param: key kABPersonAddressKey to convert
    */
    init(key: String) {
        switch (key) {
            case kABPersonAddressCityKey as! String:
                self = .City
            case kABPersonAddressStateKey as! String:
                self = .State
            case kABPersonAddressZIPKey as! String:
                self = .ZipCode
            case kABPersonAddressCountryKey as! String:
                self = .Country
            case kABPersonAddressCountryCodeKey as! String:
                self = .CountryCode
            default:
                self = .Street
        }
    }
    
    /**
        Get kABPersonAddressKey From Self Value

        :returns: kABPersonAddressKey that the self value corresponds to
    */
    var getABAddressPropertyKey: String {
        get {
            switch (self) {
            case .City:
                return kABPersonAddressCityKey as! String
            case .State:
                return kABPersonAddressStateKey as! String
            case .ZipCode:
                return kABPersonAddressZIPKey as! String
            case .Country:
                return kABPersonAddressCountryKey as! String
            case .CountryCode:
                return kABPersonAddressCountryCodeKey as! String
            default:
                return kABPersonAddressStreetKey as! String
            }
        }
    }
}