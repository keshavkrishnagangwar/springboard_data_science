import matplotlib.pyplot as plt

from sklearn.metrics import accuracy_score
from sklearn.metrics import roc_curve
from sklearn.metrics import roc_auc_score
from sklearn.metrics import average_precision_score
from sklearn.metrics import precision_recall_curve

class Model():

    def __init__(self, classifier, data):
        self.classifier = classifier
        self.data = data

    def model_eval(self, cv=False):
        """This method is used to evaluate model performance. It takes a fitted classification model and
        generates an accuracy score and plots an ROC curve."""

        # extract data
        X_train, X_test, y_train, y_test = self.data

        # calculate predicted probabilities
        y_pred_prob = self.fitted_model.predict_proba(X_test)[:,1]

        # Generate ROC curve values: fpr, tpr, thresholds
        fpr, tpr, thresholds = roc_curve(y_test, y_pred_prob)
        
        
        

        # display results
        print(f'Accuracy on the training data is {round(accuracy_score(y_train, self.fitted_model.predict(X_train)), 3)}.')

        # display model accuracy
        print(f'Accuracy on the test data is {round(accuracy_score(y_test, self.fitted_model.predict(X_test)), 3)}.')


        if cv:
            print(f'The best parameters are {self.fitted_model.best_params_}.')


    def model_performance(self, cv=False):
        """This method fits and evaluates a model. Input parameter is classifier type.
        Cv indicates whether evaluating cross validation performance."""

        # extract data
        X_train, X_test, y_train, y_test = self.data
        # initiate classifier
        clf = self.classifier
        # fit model
        self.fitted_model = clf.fit(X_train, y_train)
        # evaluate model
        self.model_eval(cv=cv)
        # return fitted model
        return clf