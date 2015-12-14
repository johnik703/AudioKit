//
//  AKDCBlock.swift
//  AudioKit
//
//  Autogenerated by scripts by Aurelius Prochazka. Do not edit directly.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/** Implements the DC blocking filter Y[i] = X[i] - X[i-1] + (igain * Y[i-1])  Based
 on work by Perry Cook. */
public class AKDCBlock: AKNode {

    // MARK: - Properties

    private var internalAU: AKDCBlockAudioUnit?
    private var token: AUParameterObserverToken?



    // MARK: - Initializers

    /** Initialize this filter node */
    public init(_ input: AKNode) {
        super.init()

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = 0x6463626b /*'dcbk'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKDCBlockAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKDCBlock",
            version: UInt32.max)

        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.output = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.AUAudioUnit as? AKDCBlockAudioUnit
            AKManager.sharedInstance.engine.attachNode(self.output!)
            AKManager.sharedInstance.engine.connect(input.output!, to: self.output!, format: AKManager.format)
        }

        guard let tree = internalAU?.parameterTree else { return }


        token = tree.tokenByAddingParameterObserver {
            address, value in

            dispatch_async(dispatch_get_main_queue()) {
            }
        }

    }
}
