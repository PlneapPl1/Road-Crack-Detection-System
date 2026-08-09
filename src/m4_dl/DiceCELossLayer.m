classdef DiceCELossLayer < nnet.layer.ClassificationLayer
    properties
        DiceWeight
        CEWeight
    end

    methods
        function layer = DiceCELossLayer(name,diceWeight,ceWeight)
            layer.Name = name;
            layer.Description = "Combined Dice and cross-entropy loss";
            layer.DiceWeight = diceWeight;
            layer.CEWeight = ceWeight;
        end

        function loss = forwardLoss(layer,Y,T)
            probabilityFloor = 1e-7;
            Y = max(Y,probabilityFloor);

            ceLoss = -sum(T.*log(Y),"all")/sum(T,"all");

            crackPrediction = Y(:,:,2,:);
            crackTarget = T(:,:,2,:);
            intersection = sum(crackPrediction.*crackTarget,"all");
            diceLoss = 1-(2*intersection+1)/( ...
                sum(crackPrediction,"all")+sum(crackTarget,"all")+1);

            weightSum = layer.DiceWeight+layer.CEWeight;
            loss = (layer.DiceWeight*diceLoss+layer.CEWeight*ceLoss)/weightSum;
        end
    end
end
