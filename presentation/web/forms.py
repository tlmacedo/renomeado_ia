from django import forms


class UploadForm(forms.Form):
    arquivo = forms.FileField()
