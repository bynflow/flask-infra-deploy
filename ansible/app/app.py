from flask import Flask, request, render_template

app = Flask(__name__)


@app.route('/')
def index():
    return '''
        <h1>Benvenuto nella Flask App!</h1>
        <p><a href="/calcola">Vai alla pagina per calcolare il quadrato</a></p>
    '''


@app.route('/ping')
def ping():
    return 'pong \n'


@app.route('/calcola', methods=['GET'])
def calc():
    expr = request.args.get("num")

    if expr == None:
        return render_template('moltiplicazione.html')
    elif expr.strip() == '':
        return "<body style='background-color:#2cc0ff;'><h1>Fottiti testa da matto!!!</h1></body>"

    result = int(expr) ** 2

    return render_template('risultato.html', quadrato=result, num=expr)



if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000, debug=True)


