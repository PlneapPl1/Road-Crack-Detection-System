classdef DiceCEBoundaryLossLayer < nnet.layer.ClassificationLayer
    properties
        DiceWeight
        CEWeight
        BoundaryWeight
    end

    methods
        function layer = DiceCEBoundaryLossLayer( ...
                name,diceWeight,ceWeight,boundaryWeight)
            layer.Name = name;
            layer.Description = ...
                "Positive-patch Dice and boundary-edge loss with cross-entropy";
            layer.DiceWeight = diceWeight;
            layer.CEWeight = ceWeight;
            layer.BoundaryWeight = boundaryWeight;
        end

        function loss = forwardLoss(layer,Y,T)
            probabilityFloor = 1e-7;
            smooth = 1;
            Y = max(Y,probabilityFloor);

            ceLoss = -sum(T.*log(Y),"all")/sum(T,"all");

            crackPrediction = Y(:,:,2,:);
            crackTarget = T(:,:,2,:);

            intersection = sum(sum(crackPrediction.*crackTarget,1),2);
            predictionMass = sum(sum(crackPrediction,1),2);
            targetMass = sum(sum(crackTarget,1),2);
            dicePerPatch = 1-(2*intersection+smooth)./( ...
                predictionMass+targetMass+smooth);
            positivePatch = targetMass > 0;
            positivePatchCount = max(sum(positivePatch,"all"),1);
            diceLoss = sum(dicePerPatch.*positivePatch,"all")/ ...
                positivePatchCount;

            predictionDx = abs(crackPrediction(:,2:end,:,:)- ...
                crackPrediction(:,1:end-1,:,:));
            targetDx = abs(crackTarget(:,2:end,:,:)- ...
                crackTarget(:,1:end-1,:,:));
            predictionDy = abs(crackPrediction(2:end,:,:,:)- ...
                crackPrediction(1:end-1,:,:,:));
            targetDy = abs(crackTarget(2:end,:,:,:)- ...
                crackTarget(1:end-1,:,:,:));

            boundaryIntersection = ...
                sum(sum(predictionDx.*targetDx,1),2)+ ...
                sum(sum(predictionDy.*targetDy,1),2);
            predictionBoundaryMass = ...
                sum(sum(predictionDx,1),2)+sum(sum(predictionDy,1),2);
            targetBoundaryMass = ...
                sum(sum(targetDx,1),2)+sum(sum(targetDy,1),2);
            boundaryPerPatch = 1-(2*boundaryIntersection+smooth)./( ...
                predictionBoundaryMass+targetBoundaryMass+smooth);
            boundaryLoss = sum(boundaryPerPatch.*positivePatch,"all")/ ...
                positivePatchCount;

            weightSum = layer.DiceWeight+layer.CEWeight+ ...
                layer.BoundaryWeight;
            loss = (layer.DiceWeight*diceLoss+ ...
                layer.CEWeight*ceLoss+ ...
                layer.BoundaryWeight*boundaryLoss)/weightSum;
        end
    end
end
