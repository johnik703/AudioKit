//
//  AKEqualizerFilter.swift
//  AudioKit
//
//  Autogenerated by scripts by Aurelius Prochazka. Do not edit directly.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/** A 2nd order tunable equalization filter that provides a peak/notch filter for
 building parametric/graphic equalizers. With gain above 1, there will be a peak
 at the center frequency with a width dependent on bandwidth. If gain is less
 than 1, a notch is formed around the center frequency. */
public class AKEqualizerFilter: AKNode {

    // MARK: - Properties

    private var internalAU: AKEqualizerFilterAudioUnit?
    private var token: AUParameterObserverToken?

    private var centerFrequencyParameter: AUParameter?
    private var bandwidthParameter: AUParameter?
    private var gainParameter: AUParameter?

    /** Center frequency. (in Hertz) */
    public var centerFrequency: Float = 1000 {
        didSet {
            centerFrequencyParameter?.setValue(centerFrequency, originator: token!)
        }
    }
    /** The peak/notch bandwidth in Hertz */
    public var bandwidth: Float = 100 {
        didSet {
            bandwidthParameter?.setValue(bandwidth, originator: token!)
        }
    }
    /** The peak/notch gain */
    public var gain: Float = 10 {
        didSet {
            gainParameter?.setValue(gain, originator: token!)
        }
    }

    // MARK: - Initializers

    /** Initialize this filter node */
    public init(
        _ input: AKNode,
        centerFrequency: Float = 1000,
        bandwidth: Float = 100,
        gain: Float = 10) {

        self.centerFrequency = centerFrequency
        self.bandwidth = bandwidth
        self.gain = gain
        super.init()

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = 0x6571666c /*'eqfl'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKEqualizerFilterAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKEqualizerFilter",
            version: UInt32.max)

        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.output = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.AUAudioUnit as? AKEqualizerFilterAudioUnit
            AKManager.sharedInstance.engine.attachNode(self.output!)
            AKManager.sharedInstance.engine.connect(input.output!, to: self.output!, format: AKManager.format)
        }

        guard let tree = internalAU?.parameterTree else { return }

        centerFrequencyParameter = tree.valueForKey("centerFrequency") as? AUParameter
        bandwidthParameter       = tree.valueForKey("bandwidth")       as? AUParameter
        gainParameter            = tree.valueForKey("gain")            as? AUParameter

        token = tree.tokenByAddingParameterObserver {
            address, value in

            dispatch_async(dispatch_get_main_queue()) {
                if address == self.centerFrequencyParameter!.address {
                    self.centerFrequency = value
                } else if address == self.bandwidthParameter!.address {
                    self.bandwidth = value
                } else if address == self.gainParameter!.address {
                    self.gain = value
                }
            }
        }

        centerFrequencyParameter?.setValue(centerFrequency, originator: token!)
        bandwidthParameter?.setValue(bandwidth, originator: token!)
        gainParameter?.setValue(gain, originator: token!)

    }
}
